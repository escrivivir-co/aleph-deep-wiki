const path = require('path');
const fs = require('fs');
const { execSync } = require('child_process');

function resolveHomeDirectory() {
  const homeDirectory = process.env.HOME || process.env.USERPROFILE;
  if (!homeDirectory) {
    throw new Error('HOME / USERPROFILE is required to resolve notebook paths.');
  }
  return homeDirectory;
}

function parseNResults(block) {
  const rangeMatch = block.match(/`n_results`:\s*(\d+)(?:[–-](\d+))?/);
  if (!rangeMatch) {
    return { raw: '5', min: 5, max: 5 };
  }
  const min = Number(rangeMatch[1]);
  const max = rangeMatch[2] ? Number(rangeMatch[2]) : min;
  return {
    raw: rangeMatch[2] ? `${min}–${max}` : `${min}`,
    min,
    max,
  };
}

function stableJson(value) {
  const source = value || {};
  const normalized = Object.keys(source)
    .sort()
    .reduce((acc, key) => {
      acc[key] = source[key];
      return acc;
    }, {});
  return JSON.stringify(normalized);
}

function cleanText(text) {
  return String(text || '').replace(/\s+/g, ' ').trim();
}

function buildSnippet(text, maxLength = 120) {
  const normalized = cleanText(text);
  if (normalized.length <= maxLength) {
    return normalized;
  }
  return normalized.slice(0, Math.max(0, maxLength - 1)).trimEnd() + '…';
}

function buildAutomaticSynthesis(section, queryResults) {
  const flatItems = queryResults.flatMap((queryResult, queryIndex) =>
    queryResult.items.map((item) => ({
      ...item,
      queryText: queryResult.queryText,
      queryIndex: queryIndex + 1,
    }))
  );

  if (!flatItems.length) {
    return {
      hallazgos: [
        `La colección \`${section.collectionName}\` no devolvió resultados para el pack ejecutado.`,
        'Conviene revisar si la colección existe y si contiene embeddings consultables.',
        'No hay todavía anclas suficientes para una lectura comparativa.',
      ],
      tensions: [
        'La ausencia de resultados impide diferenciar ruido de silencio del corpus.',
        'Sin hits, no puede estimarse si el problema está en la query o en la colección.',
      ],
      hypothesis: section.hypothesis || 'Hipótesis pendiente hasta disponer de resultados.',
    };
  }

  const frequencyMap = new Map();
  flatItems.forEach((item) => {
    const current = frequencyMap.get(item.id) || { id: item.id, count: 0 };
    current.count += 1;
    frequencyMap.set(item.id, current);
  });

  const recurring = [...frequencyMap.values()]
    .sort((left, right) => right.count - left.count || left.id.localeCompare(right.id))
    .slice(0, 3);

  const bestHit = [...flatItems].sort((left, right) => left.distance - right.distance)[0];
  const metadataSections = [...new Set(flatItems.map((item) => (item.metadata && item.metadata.seccion ? String(item.metadata.seccion) : '?')))];
  const titles = [...new Set(flatItems.map((item) => (item.metadata && item.metadata.titulo ? String(item.metadata.titulo) : item.id)))];

  const hallazgos = [
    recurring[0]
      ? `La pieza más recurrente del pack es \`${recurring[0].id}\` (${recurring[0].count} apariciones en resultados top).`
      : `La recuperación se concentra en un único ancla de \`${section.collectionName}\`.`,
    `La mejor coincidencia global llega con \`${bestHit.id}\` para la query «${bestHit.queryText}» (distance ${bestHit.distance.toFixed(4)}).`,
    metadataSections.length
      ? `La cobertura de \`metadata.seccion\` recorre ${metadataSections.map((label) => `\`${label}\``).join(', ')}.`
      : 'La cobertura no expone marcas de sección utilizables.',
  ];

  const tensions = [
    metadataSections.some((label) => /^0$|^1/.test(label)) && metadataSections.some((label) => /^4/.test(label))
      ? `Conviven materiales de marco/origen (${metadataSections.filter((label) => /^0$|^1/.test(label)).map((label) => `\`${label}\``).join(', ')}) y materiales de cristalización tardía (${metadataSections.filter((label) => /^4/.test(label)).map((label) => `\`${label}\``).join(', ')}).`
      : 'Los resultados tienden a concentrarse en una misma zona narrativa del corpus.',
    titles.length > 1
      ? `Los hits alternan entre ${titles.slice(0, 2).map((title) => `\`${title}\``).join(' y ')}${titles.length > 2 ? ', señal de pluralidad semántica.' : '.'}`
      : 'La recuperación es compacta y gira casi por completo sobre un mismo nodo semántico.',
  ];

  const cleanedHypothesis = section.hypothesis
    ? section.hypothesis.replace(/^¿/, '').replace(/\?$/, '')
    : `seguir el documento ancla \`${bestHit.id}\` y sus repeticiones cruzadas`;

  return {
    hallazgos,
    tensions,
    hypothesis: `Hipótesis operativa: ${cleanedHypothesis}.`,
  };
}

function renderSectionMarkdown(section, queryResults) {
  const synthesis = buildAutomaticSynthesis(section, queryResults);
  const lines = [];

  lines.push(`# Sección ${section.sectionNumber} — \`${section.collectionName}\``);
  lines.push('');
  lines.push('## Confirmación de detalle (sí, se puede)');
  lines.push('Con `vector-machine mcp` / Chroma se registra el mismo nivel operativo de detalle que en Admin UI:');
  lines.push('- `distance`');
  lines.push('- `id`');
  lines.push('- `document`');
  lines.push('- `metadata`');
  lines.push('');
  lines.push('> Nota técnica: menor `distance` = mayor cercanía semántica.');
  lines.push('');
  lines.push('## Configuración de la sección');
  lines.push(`- **Colección:** \`${section.collectionName}\``);
  lines.push(`- **Etiqueta:** ${section.sectionLabel}`);
  lines.push(`- **Agente sugerido:** \`${section.agent}\``);
  lines.push(`- **Hipótesis:** ${section.hypothesis}`);
  lines.push(`- **n_results ejecutado:** ${section.nResults.min}`);
  lines.push('');
  lines.push('## Query pack ejecutado');
  lines.push(`Colección: \`${section.collectionName}\`  `);
  lines.push(`\`n_results\`: ${section.nResults.min} por query`);
  lines.push('');
  section.queryTexts.forEach((queryText, index) => {
    lines.push(`${index + 1}. "${queryText}"`);
  });
  lines.push('');
  lines.push('---');
  lines.push('');
  lines.push(`## Resultados detallados (top-${section.nResults.min} por query)`);
  lines.push('');

  queryResults.forEach((queryResult, queryIndex) => {
    lines.push(`### Q${queryIndex + 1}) ${queryResult.queryText}`);
    if (!queryResult.items.length) {
      lines.push('- Sin resultados.');
      lines.push('');
      return;
    }

    queryResult.items.forEach((item, itemIndex) => {
      lines.push(`${itemIndex + 1}. **${item.distance.toFixed(4)}** — \`${item.id}\` — ${buildSnippet(item.document, 120)}  `);
      lines.push(`   \`${stableJson(item.metadata)}\``);
    });
    lines.push('');
  });

  lines.push('---');
  lines.push('');
  lines.push('## Cierre de sección (síntesis automática)');
  lines.push('### Hallazgos clave');
  synthesis.hallazgos.forEach((hallazgo) => {
    lines.push(`- ${hallazgo}`);
  });
  lines.push('');
  lines.push('### Tensiones o contradicciones');
  synthesis.tensions.forEach((tension) => {
    lines.push(`- ${tension}`);
  });
  lines.push('');
  lines.push('### Hipótesis operativa');
  lines.push(`- ${synthesis.hypothesis}`);
  lines.push('');

  return lines.join('\n');
}

async function main() {
  const HOME_DIR = resolveHomeDirectory();
  const SCRIPTORIUM_ROOT = path.join(HOME_DIR, 'OASIS', 'aleph-scriptorium');
  const WORKSPACE_ROOT = path.join('c:', 'Users', 'aleph', 'Desktop', 'TEST');
  const TMP_DIR = path.join(WORKSPACE_ROOT, 'tmp');
  const TEMPLATE_FILE = path.join(TMP_DIR, 'plantilla-semantic-query-ml.md');
  const NNB_DIR = path.join(SCRIPTORIUM_ROOT, 'VectorMachineSDK');
  const VECTOR_DB_DIST = path.join(SCRIPTORIUM_ROOT, 'MCPGallery', 'mcp-core-sdk', 'dist', 'vector-db');

  const neededPackages = ['chromadb-default-embed'];
  const missingPackages = neededPackages.filter((pkg) => !fs.existsSync(path.join(NNB_DIR, 'node_modules', pkg)));
  if (missingPackages.length) {
    console.log(`📦 Instalando dependencias notebook: ${missingPackages.join(', ')}`);
    execSync(`npm install ${missingPackages.join(' ')}`, { cwd: NNB_DIR, stdio: 'pipe' });
  }

  const coreExports = require(VECTOR_DB_DIST);
  const BasicVectorMachine = coreExports.BasicVectorMachine;
  if (!BasicVectorMachine) {
    throw new Error(`BasicVectorMachine no encontrado en ${VECTOR_DB_DIST}.`);
  }

  const vm = new BasicVectorMachine();
  const client = vm.getChromaClient();
  const heartbeat = await vm.connectChroma();
  const mlCollections = await vm.listCollectionNames('ml_');
  console.log(`🧭 Chroma heartbeat: ${heartbeat}`);
  console.log(`Colecciones ml_*: ${mlCollections.join(', ')}`);

  const templateMarkdown = fs.readFileSync(TEMPLATE_FILE, 'utf8');
  const sectionHeaderRegex = /^##\s+(\d+)\)\s+`([^`]+)`\s+—\s+(.+)$/gm;
  const sectionMatches = [...templateMarkdown.matchAll(sectionHeaderRegex)];
  if (sectionMatches.length !== 5) {
    throw new Error(`El parser esperaba 5 secciones y encontró ${sectionMatches.length}.`);
  }

  const sections = sectionMatches.map((match, index) => {
    const start = match.index;
    const end = index + 1 < sectionMatches.length ? sectionMatches[index + 1].index : templateMarkdown.length;
    const block = templateMarkdown.slice(start, end).trim();
    const sectionNumber = Number(match[1]);
    const collectionName = match[2].trim();
    const sectionLabel = match[3].trim();
    const agentMatch = block.match(/\*\*Agente sugerido:\*\*\s*`([^`]+)`/);
    const hypothesisMatch = block.match(/###\s+Hipótesis de exploración\s*\n-\s+(.+)/);
    const queryTexts = [...block.matchAll(/^\d+\.\s+"([^"]+)"/gm)].map((queryMatch) => queryMatch[1].trim());
    const nResults = parseNResults(block);

    return {
      sectionNumber,
      collectionName,
      sectionLabel,
      agent: agentMatch ? agentMatch[1].trim() : 'Explore',
      hypothesis: hypothesisMatch ? hypothesisMatch[1].trim() : '',
      queryTexts,
      nResults,
      outputPath: path.join(TMP_DIR, `seccion-${sectionNumber}-${collectionName}.md`),
    };
  });

  const invalidSections = sections.filter((section) => !mlCollections.includes(section.collectionName));
  if (invalidSections.length) {
    throw new Error(`Colecciones ausentes en Chroma: ${invalidSections.map((section) => section.collectionName).join(', ')}`);
  }

  const { pipeline, env } = require(path.join(NNB_DIR, 'node_modules', 'chromadb-default-embed'));
  env.cacheDir = path.join(NNB_DIR, '.model-cache');
  const embedder = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');

  async function queryCollection(collectionName, queryTexts, nResults) {
    const collection = await client.getCollection({
      name: collectionName,
      embeddingFunction: { generate: async () => [] },
    });

    const embeddingOutput = await embedder(queryTexts, { pooling: 'mean', normalize: true });
    const queryEmbeddings = embeddingOutput.tolist();
    const queryResults = [];

    for (let index = 0; index < queryTexts.length; index += 1) {
      const result = await collection.query({
        queryEmbeddings: [queryEmbeddings[index]],
        nResults,
        include: ['documents', 'metadatas', 'distances'],
      });

      const ids = (result.ids && result.ids[0]) || [];
      const documents = (result.documents && result.documents[0]) || [];
      const metadatas = (result.metadatas && result.metadatas[0]) || [];
      const distances = (result.distances && result.distances[0]) || [];

      const items = ids
        .map((id, itemIndex) => ({
          id,
          document: documents[itemIndex] || '',
          metadata: metadatas[itemIndex] || {},
          distance: Number(distances[itemIndex]),
        }))
        .sort((left, right) => left.distance - right.distance);

      queryResults.push({ queryText: queryTexts[index], items });
    }

    return queryResults;
  }

  const outputs = [];
  for (const section of sections) {
    const queryResults = await queryCollection(section.collectionName, section.queryTexts, section.nResults.min);
    const markdown = renderSectionMarkdown(section, queryResults);
    fs.writeFileSync(section.outputPath, markdown, 'utf8');
    outputs.push({
      section: section.sectionNumber,
      collection: section.collectionName,
      file: path.basename(section.outputPath),
      queries: section.queryTexts.length,
      nResults: section.nResults.min,
    });
  }

  console.table(outputs);
  console.log(`✓ Se escribieron ${outputs.length} archivos de sección en ${TMP_DIR}`);
}

main().catch((error) => {
  console.error(error && error.stack ? error.stack : error);
  process.exit(1);
});
