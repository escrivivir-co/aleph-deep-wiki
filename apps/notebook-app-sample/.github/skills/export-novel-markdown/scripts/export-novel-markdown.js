#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function fail(message, extra = {}) {
  const payload = { error: message, ...extra };
  process.stderr.write(`${JSON.stringify(payload, null, 2)}\n`);
  process.exit(1);
}

function parseArgs(argv) {
  const args = { overwrite: false };

  for (let index = 2; index < argv.length; index += 1) {
    const current = argv[index];

    if (!current.startsWith('--')) {
      fail(`Unexpected argument: ${current}`);
    }

    const key = current.slice(2);

    if (key === 'overwrite') {
      args.overwrite = true;
      continue;
    }

    const value = argv[index + 1];
    if (!value || value.startsWith('--')) {
      fail(`Missing value for argument --${key}`);
    }

    args[key] = value;
    index += 1;
  }

  return args;
}

function slugify(value) {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .replace(/-{2,}/g, '-');
}

function readJson(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (error) {
    fail('Failed to read JSON data file.', {
      filePath,
      details: error instanceof Error ? error.message : String(error),
    });
  }
}

function ensureWritableOutput(filePath, overwrite) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });

  if (fs.existsSync(filePath) && !overwrite) {
    fail('Output file already exists. Pass --overwrite to replace it.', {
      outputPath: filePath,
    });
  }
}

function paragraph(text) {
  const trimmed = (text || '').trim();
  return trimmed.length > 0 ? trimmed : '_Sin contenido._';
}

function renderCharacter(character) {
  const lines = [];
  lines.push(`### ${character.name}`);
  lines.push('');
  lines.push(`- **ID**: \`${character.id}\``);
  lines.push(`- **Descripción**: ${character.description || '_Sin descripción._'}`);
  lines.push(`- **Rasgos**: ${(character.traits || []).length > 0 ? character.traits.join(', ') : '_Sin rasgos._'}`);

  if (character.backstory && character.backstory.trim()) {
    lines.push('- **Trasfondo**:');
    lines.push('');
    lines.push(paragraph(character.backstory));
  }

  lines.push('');
  return lines;
}

function renderScene(scene, charactersById, sceneNumber) {
  const characterNames = (scene.characters || []).map((characterId) => {
    const character = charactersById[characterId];
    return character ? character.name : characterId;
  });

  const lines = [];
  lines.push(`### Escena ${sceneNumber} — ${scene.title}`);
  lines.push('');
  lines.push(`- **Scene ID**: \`${scene.id}\``);
  lines.push(`- **Setting**: ${scene.setting || '_Sin setting._'}`);
  lines.push(`- **Personajes**: ${characterNames.length > 0 ? characterNames.join(', ') : '_Sin personajes asignados._'}`);
  lines.push(`- **Resumen estructural**: ${scene.summary || '_Sin resumen._'}`);
  lines.push('');

  if (scene.content && scene.content.trim()) {
    lines.push(scene.content.trim());
  } else {
    lines.push(`> _Escena sin prosa final todavía. Resumen de trabajo:_ ${scene.summary || 'Sin resumen.'}`);
  }

  lines.push('');
  return lines;
}

function renderChapter(chapter, chapterIndex, scenesById, charactersById) {
  const lines = [];
  lines.push(`## ${chapter.title}`);
  lines.push('');
  lines.push(`- **Capítulo ${chapterIndex}** · **ID**: \`${chapter.id}\` · **Escenas**: ${(chapter.scenes || []).length}`);
  lines.push(`- **Resumen**: ${chapter.summary || '_Sin resumen._'}`);
  lines.push('');

  (chapter.scenes || []).forEach((sceneId, sceneIndex) => {
    const scene = scenesById[sceneId];

    if (!scene) {
      lines.push(`### Escena ${sceneIndex + 1} — [${sceneId}]`);
      lines.push('');
      lines.push('> _Escena referenciada pero no encontrada en el contenedor._');
      lines.push('');
      return;
    }

    lines.push(...renderScene(scene, charactersById, sceneIndex + 1));
  });

  return lines;
}

function renderNovelMarkdown({ novel, chapters, characters, scenesById, charactersById, exportedAt }) {
  const totalScenes = chapters.reduce((count, chapter) => count + (chapter.scenes || []).length, 0);
  const scenesWithContent = chapters.flatMap((chapter) => chapter.scenes || [])
    .map((sceneId) => scenesById[sceneId])
    .filter((scene) => scene && scene.content && scene.content.trim().length > 0)
    .length;

  const lines = [];
  lines.push(`# ${novel.title}`);
  lines.push('');
  lines.push(`> Exportado desde \`NovelistEditor\` el ${exportedAt}`);
  lines.push('');
  lines.push(`- **Novel ID**: \`${novel.id}\``);
  lines.push(`- **Autor**: ${novel.author || '_Sin autor._'}`);
  lines.push(`- **Géneros**: ${(novel.genre || []).length > 0 ? novel.genre.join(', ') : '_Sin géneros._'}`);
  lines.push(`- **Capítulos**: ${chapters.length}`);
  lines.push(`- **Escenas**: ${totalScenes}`);
  lines.push(`- **Personajes**: ${characters.length}`);
  lines.push(`- **Escenas con prosa final**: ${scenesWithContent}`);
  lines.push(`- **Escenas en modo esquema**: ${totalScenes - scenesWithContent}`);
  lines.push('');
  lines.push('## Resumen');
  lines.push('');
  lines.push(paragraph(novel.summary));
  lines.push('');
  lines.push('## Setting');
  lines.push('');
  lines.push(paragraph(novel.setting));
  lines.push('');
  lines.push('## Índice de capítulos');
  lines.push('');

  chapters.forEach((chapter, index) => {
    lines.push(`${index + 1}. ${chapter.title} (${(chapter.scenes || []).length} escenas)`);
  });

  lines.push('');
  lines.push('## Personajes');
  lines.push('');

  characters.forEach((character) => {
    lines.push(...renderCharacter(character));
  });

  chapters.forEach((chapter, index) => {
    lines.push(...renderChapter(chapter, index + 1, scenesById, charactersById));
  });

  lines.push('## Apéndice de exportación');
  lines.push('');
  lines.push(`- **Origen**: \`src/resources/novel-data.json\``);
  lines.push(`- **Modo de exportación**: contenido completo cuando existe; resumen estructural como fallback.`);
  lines.push(`- **Slug sugerido**: \`${slugify(novel.title)}\``);
  lines.push('');

  return `${lines.join('\n').replace(/\n{3,}/g, '\n\n')}\n`;
}

(function main() {
  const args = parseArgs(process.argv);
  const dataFilePath = args.data ? path.resolve(args.data) : '';
  const novelId = args.novelId || '';
  const outputPath = args.out ? path.resolve(args.out) : '';

  if (!dataFilePath || !novelId || !outputPath) {
    fail('Missing required arguments. Expected --data, --novelId and --out.');
  }

  const payload = readJson(dataFilePath);
  const resources = payload.resources || {};
  const novelsById = resources.novels || {};
  const chaptersById = resources.chapters || {};
  const scenesById = resources.scenes || {};
  const charactersById = resources.characters || {};

  const novel = novelsById[novelId];
  if (!novel) {
    fail('Novel not found in data file.', { novelId, dataFilePath });
  }

  const chapters = (novel.chapters || [])
    .map((chapterId) => chaptersById[chapterId])
    .filter(Boolean);

  const characters = (novel.characters || [])
    .map((characterId) => charactersById[characterId])
    .filter(Boolean);

  const exportedAt = new Date().toISOString();
  const markdown = renderNovelMarkdown({
    novel,
    chapters,
    characters,
    scenesById,
    charactersById,
    exportedAt,
  });

  ensureWritableOutput(outputPath, args.overwrite);
  fs.writeFileSync(outputPath, markdown, 'utf8');

  const summary = {
    novelId,
    title: novel.title,
    outputPath,
    exportedAt,
    counts: {
      chapters: chapters.length,
      scenes: chapters.reduce((count, chapter) => count + (chapter.scenes || []).length, 0),
      characters: characters.length,
    },
  };

  process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);
})();
