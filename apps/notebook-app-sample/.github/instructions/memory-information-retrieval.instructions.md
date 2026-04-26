# Memory Information Retrieval Instructions

## Overview
This guide provides detailed instructions for querying, searching, and retrieving information from novel-books memory structures using the MCP Novelist server. Focus on extracting actionable insights and comprehensive reports from stored memory.

## Prerequisites
- Populated memory containers with characters, scenes, and chapters
- Access to MCP tools in VS Code Copilot Chat
- Understanding of memory structure relationships

## Information Retrieval Categories

### Discovery Operations
Find what memory structures exist and explore their contents

### Detailed Retrieval Operations
Get comprehensive information about specific memory elements

### Analysis Operations
Generate reports, timelines, and cross-reference analyses

### Search Operations
Find specific information across memory structures

## Discovery and Navigation

### Memory Container Discovery
```javascript
// List all available memory containers
alephAlpha_listNovels()

// Get overview of specific container
alephAlpha_getNovelDetails(novelId)

// Resource-based exploration
resources/list
resources/read "aleph://novel/{novelId}"
```

### Content Element Discovery
```javascript
// Discover entities/people/systems
alephAlpha_listCharacters()                    // All characters across projects
alephAlpha_listCharacters(novelId)             // Characters in specific project

// Discover events/interactions
alephAlpha_listScenes()                        // All scenes across projects
alephAlpha_listScenesByNovel(novelId)          // Scenes in specific project
alephAlpha_listScenesByChapter(chapterId)      // Scenes in specific phase
```

### Navigation Interface
```javascript
// HTML interface for browsing
resources/read "aleph://resources/index"       // Interactive memory browser
```

## Detailed Information Retrieval

### Character (Entity) Details
```javascript
// Get comprehensive entity information
alephAlpha_getCharacterDetails(characterId)

// Resource-based access with relationships
resources/read "aleph://novel/character/{characterId}"
```

**Use Cases**:
- Understanding stakeholder details and preferences
- Reviewing system capabilities and constraints
- Analyzing entity relationships across projects

### Scene (Event) Details
```javascript
// Get comprehensive event information
alephAlpha_getScene(sceneId)

// Resource-based access with character details included
resources/read "aleph://novel/scene/{sceneId}"
```

**Use Cases**:
- Reviewing meeting outcomes and decisions
- Understanding incident timelines and resolutions
- Analyzing project milestones and progress

### Chapter (Phase) Analysis
```javascript
// Get all scenes within a phase
alephAlpha_listScenesByChapter(chapterId)

// Then retrieve details for each scene
scenes.forEach(scene => alephAlpha_getScene(scene.id))
```

**Use Cases**:
- Analyzing project phase outcomes
- Understanding temporal sequences
- Reviewing phase-specific decisions and learnings

## Specialized Query Patterns

### Stakeholder Interaction Analysis
```javascript
// Find all interactions with specific person
const allScenes = await alephAlpha_listScenes();
const stakeholderScenes = allScenes.filter(scene => 
  scene.characters.includes('sarah-mitchell-client-lead')
);

// Create interaction timeline
const interactionTimeline = stakeholderScenes
  .sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp))
  .map(scene => ({
    date: scene.timestamp,
    event: scene.title,
    context: scene.setting,
    outcome: scene.summary
  }));
```

**Output**: Chronological view of all interactions with specific stakeholder

### Cross-Project Entity Analysis
```javascript
// Find entity across multiple projects
const allNovels = await alephAlpha_listNovels();
const entityAppearances = [];

for (const novel of allNovels) {
  const characters = await alephAlpha_listCharacters(novel.id);
  const entityInProject = characters.find(char => 
    char.name.includes('target-entity-name')
  );
  
  if (entityInProject) {
    const projectScenes = await alephAlpha_listScenesByNovel(novel.id);
    const entityScenes = projectScenes.filter(scene =>
      scene.characters.includes(entityInProject.id)
    );
    
    entityAppearances.push({
      project: novel.title,
      character: entityInProject,
      interactions: entityScenes.length,
      scenes: entityScenes
    });
  }
}
```

**Output**: Entity involvement across multiple projects

### Decision Tracking Analysis
```javascript
// Find all decision-related scenes
const allScenes = await alephAlpha_listScenes();
const decisionScenes = allScenes.filter(scene =>
  scene.title.toLowerCase().includes('decision') ||
  scene.summary.toLowerCase().includes('decided') ||
  scene.content.toLowerCase().includes('decision:')
);

// Organize by project and chronology
const decisionsByProject = decisionScenes.reduce((acc, scene) => {
  const projectId = scene.novelId;
  if (!acc[projectId]) acc[projectId] = [];
  acc[projectId].push(scene);
  return acc;
}, {});
```

**Output**: Comprehensive decision history across projects

### Technical System Analysis
```javascript
// Find all system-related characters
const allCharacters = await alephAlpha_listCharacters();
const systemCharacters = allCharacters.filter(char =>
  char.traits.some(trait => 
    trait.includes('api') || 
    trait.includes('database') || 
    trait.includes('service') ||
    trait.includes('system')
  )
);

// For each system, find related scenes
const systemAnalysis = await Promise.all(
  systemCharacters.map(async (system) => {
    const allScenes = await alephAlpha_listScenes();
    const systemScenes = allScenes.filter(scene =>
      scene.characters.includes(system.id)
    );
    
    return {
      system: system.name,
      description: system.description,
      capabilities: system.traits,
      interactions: systemScenes.length,
      incidents: systemScenes.filter(scene => 
        scene.title.toLowerCase().includes('incident') ||
        scene.title.toLowerCase().includes('issue')
      ),
      decisions: systemScenes.filter(scene =>
        scene.title.toLowerCase().includes('decision')
      )
    };
  })
);
```

**Output**: Comprehensive technical infrastructure analysis

## Report Generation Patterns

### Project Memory Report
```javascript
async function generateProjectReport(novelId) {
  const novel = await alephAlpha_getNovelDetails(novelId);
  const characters = await alephAlpha_listCharacters(novelId);
  const scenes = await alephAlpha_listScenesByNovel(novelId);
  
  // Organize by chapters if available
  const chapters = novel.chapterDetails || [];
  const chapterAnalysis = await Promise.all(
    chapters.map(async (chapter) => {
      const chapterScenes = await alephAlpha_listScenesByChapter(chapter.id);
      return {
        phase: chapter.title,
        summary: chapter.summary,
        events: chapterScenes.length,
        key_events: chapterScenes.filter(scene => 
          scene.title.toLowerCase().includes('decision') ||
          scene.title.toLowerCase().includes('milestone')
        )
      };
    })
  );
  
  return {
    project: novel.title,
    timeframe: novel.setting,
    stakeholders: characters.length,
    total_events: scenes.length,
    phase_analysis: chapterAnalysis,
    key_stakeholders: characters.filter(char => 
      scenes.filter(scene => scene.characters.includes(char.id)).length > 3
    ),
    recent_activity: scenes
      .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
      .slice(0, 5),
    decision_summary: scenes.filter(scene =>
      scene.title.toLowerCase().includes('decision')
    )
  };
}
```

### Stakeholder Interaction Map
```javascript
async function generateStakeholderMap(characterId) {
  const character = await alephAlpha_getCharacterDetails(characterId);
  const allScenes = await alephAlpha_listScenes();
  
  const characterScenes = allScenes.filter(scene =>
    scene.characters.includes(characterId)
  );
  
  // Find all other characters they've interacted with
  const interactions = {};
  characterScenes.forEach(scene => {
    scene.characters.forEach(otherId => {
      if (otherId !== characterId) {
        if (!interactions[otherId]) {
          interactions[otherId] = {
            scenes: [],
            interaction_count: 0
          };
        }
        interactions[otherId].scenes.push(scene);
        interactions[otherId].interaction_count++;
      }
    });
  });
  
  // Get details for all interacted characters
  const interactionDetails = await Promise.all(
    Object.keys(interactions).map(async (otherId) => {
      const otherCharacter = await alephAlpha_getCharacterDetails(otherId);
      return {
        name: otherCharacter.name,
        role: otherCharacter.description,
        interaction_frequency: interactions[otherId].interaction_count,
        recent_interactions: interactions[otherId].scenes
          .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
          .slice(0, 3),
        relationship_context: interactions[otherId].scenes.map(scene => ({
          event: scene.title,
          outcome: scene.summary
        }))
      };
    })
  );
  
  return {
    stakeholder: character.name,
    role: character.description,
    preferences: character.traits,
    total_interactions: characterScenes.length,
    interaction_network: interactionDetails,
    communication_patterns: analyzeCommuncationPatterns(characterScenes),
    project_involvement: await findProjectInvolvement(characterId)
  };
}
```

### Knowledge Base Index
```javascript
async function generateKnowledgeIndex() {
  const allNovels = await alephAlpha_listNovels();
  const allScenes = await alephAlpha_listScenes();
  const allCharacters = await alephAlpha_listCharacters();
  
  // Index by topics (extracted from scenes)
  const topicIndex = {};
  allScenes.forEach(scene => {
    const topics = extractTopics(scene.title + ' ' + scene.summary + ' ' + scene.content);
    topics.forEach(topic => {
      if (!topicIndex[topic]) topicIndex[topic] = [];
      topicIndex[topic].push({
        scene: scene.title,
        context: scene.summary,
        project: scene.novelId,
        relevance: calculateRelevance(scene, topic)
      });
    });
  });
  
  // Index by technologies (extracted from characters and scenes)
  const technologyIndex = extractTechnologies(allCharacters, allScenes);
  
  // Index by decisions
  const decisionIndex = allScenes
    .filter(scene => scene.title.toLowerCase().includes('decision'))
    .map(scene => ({
      decision: extractDecision(scene.title),
      context: scene.summary,
      project: scene.novelId,
      outcome: scene.content,
      date: scene.timestamp
    }));
  
  return {
    projects: allNovels.length,
    total_events: allScenes.length,
    total_entities: allCharacters.length,
    topic_index: topicIndex,
    technology_index: technologyIndex,
    decision_index: decisionIndex,
    most_active_projects: findMostActiveProjects(allNovels, allScenes),
    key_stakeholders: findKeyStakeholders(allCharacters, allScenes)
  };
}
```

## Search and Filter Operations

### Temporal Queries
```javascript
// Events within date range
const recentScenes = allScenes.filter(scene => {
  const sceneDate = new Date(scene.timestamp);
  const startDate = new Date('2024-01-01');
  const endDate = new Date('2024-12-31');
  return sceneDate >= startDate && sceneDate <= endDate;
});

// Project phases analysis
const phaseAnalysis = chapters.map(chapter => ({
  phase: chapter.title,
  duration: calculatePhaseDuration(chapter),
  event_density: chapter.scenes.length,
  key_outcomes: extractKeyOutcomes(chapter)
}));
```

### Content-Based Search
```javascript
// Search across all content
function searchMemoryContent(searchTerm) {
  const results = [];
  
  // Search in scenes
  allScenes.forEach(scene => {
    if (scene.content.toLowerCase().includes(searchTerm.toLowerCase()) ||
        scene.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        scene.summary.toLowerCase().includes(searchTerm.toLowerCase())) {
      results.push({
        type: 'scene',
        title: scene.title,
        context: scene.summary,
        relevance: calculateSearchRelevance(scene, searchTerm)
      });
    }
  });
  
  // Search in characters
  allCharacters.forEach(character => {
    if (character.backstory.toLowerCase().includes(searchTerm.toLowerCase()) ||
        character.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
        character.name.toLowerCase().includes(searchTerm.toLowerCase())) {
      results.push({
        type: 'character',
        name: character.name,
        context: character.description,
        relevance: calculateSearchRelevance(character, searchTerm)
      });
    }
  });
  
  return results.sort((a, b) => b.relevance - a.relevance);
}
```

## Export and Integration

### Formatted Report Export
```javascript
// Generate markdown report
function exportProjectMarkdown(projectReport) {
  return `
# ${projectReport.project} - Memory Report

## Project Overview
- **Timeframe**: ${projectReport.timeframe}
- **Stakeholders**: ${projectReport.stakeholders}
- **Total Events**: ${projectReport.total_events}

## Phase Analysis
${projectReport.phase_analysis.map(phase => `
### ${phase.phase}
- **Summary**: ${phase.summary}
- **Events**: ${phase.events}
- **Key Events**: ${phase.key_events.length}
`).join('')}

## Key Stakeholders
${projectReport.key_stakeholders.map(stakeholder => `
- **${stakeholder.name}**: ${stakeholder.description}
`).join('')}

## Recent Activity
${projectReport.recent_activity.map(event => `
- **${event.title}**: ${event.summary}
`).join('')}

## Decision Summary
${projectReport.decision_summary.map(decision => `
- **${decision.title}**: ${decision.summary}
`).join('')}
  `;
}
```

### JSON Data Export
```javascript
// Export structured data
function exportStructuredData(novelId) {
  return {
    export_date: new Date().toISOString(),
    project: novel,
    entities: characters,
    events: scenes,
    phases: chapters,
    relationships: generateRelationshipMap(),
    metadata: {
      total_entities: characters.length,
      total_events: scenes.length,
      date_range: calculateDateRange(scenes)
    }
  };
}
```

## Performance Optimization

### Efficient Querying
- Use specific novel IDs when possible to limit scope
- Cache frequently accessed character and scene details
- Batch related queries to minimize round trips
- Use resource URIs for structured data access

### Memory Management
- Process large datasets in chunks
- Use streaming for large report generation
- Implement pagination for large result sets
- Cache intermediate results for complex analyses

## Troubleshooting Retrieval Operations

### Common Issues
- **Empty Results**: Verify data exists with discovery operations first
- **Slow Queries**: Use targeted queries instead of broad searches
- **Missing Relationships**: Check character IDs in scene associations
- **Date Issues**: Verify timestamp format and time zone considerations

### Validation Steps
1. Confirm server connectivity with `resources/read "aleph://server/info"`
2. Verify data exists with `alephAlpha_listNovels()`
3. Check specific container with `alephAlpha_getNovelDetails(novelId)`
4. Validate relationships with character and scene lists

### Error Recovery
- Use manual save before complex operations
- Implement graceful fallbacks for missing data
- Provide partial results when complete data unavailable
- Document data quality issues for future improvement