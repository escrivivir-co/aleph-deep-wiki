# MCP Novelist - Long-term Memory System with Novel-based Data Structures

You are an expert developer working with the **MCP Novelist Server** - a Model Context Protocol (MCP) implementation that provides long-term memory capabilities through novel-based data structures. This server enables persistent storage and intelligent retrieval of complex information organized as novels, books, chapters, characters, and scenes.

## Aleph Scriptorium Integration

**This NovelistEditor is a component of [Aleph Scriptorium](https://escrivivir-co.github.io/aleph-scriptorium/)** - an AI agent system for VS Code + GitHub Copilot Chat designed for large-scale writing projects.

### For Scriptorium Writers

If you are a writer from Aleph Scriptorium:

1. **Use the `@escritor` agent** for writing sessions
2. **Context file**: `scriptorium-context.json` contains paths to your novels
3. **Available novels** are stored in `ARCHIVO/PLUGINS/NOVELIST/obras/`

### Quick Start for Writers

```bash
# Initialize connection to Scriptorium (first time)
npm run init:scriptorium

# Or specify a custom path
npm run init:scriptorium -- --scriptorium-root /path/to/scriptorium

# Start MCP server (optional, for full capabilities)
npm start
```

### Custom Agents Available

| Agent | Purpose | Use when |
|-------|---------|----------|
| `@escritor` | Writing sessions | You want to work on a novel |
| `@editor` | Container management | Initialize, recover, configure |
| `@albacea` | Content creation | Add characters, scenes, chapters |
| `@lector` | Information retrieval | Search, index, analyze |

---

## Core Concept

**MCP Novelist is NOT primarily about literature or creative writing development.** Instead, it's a sophisticated long-term memory system that uses the familiar metaphor of novels and books to organize, store, and retrieve any kind of complex information with rich relationships and hierarchical structures.

### Why Novel-based Memory?
- **Hierarchical Organization**: Novels → Chapters → Scenes (perfect for complex project structures)
- **Character Relationships**: Track entities and their interactions across different contexts
- **Temporal Continuity**: Maintain chronological understanding through scene sequences
- **Rich Context**: Store detailed descriptions, settings, and relationships
- **Cross-references**: Characters can appear in multiple scenes, creating natural data linking

## Server Architecture & Connection

### Quick Start
```bash
# Start the MCP Novelist server
npm run dev          # Development mode (port 3066)
npm start           # Production mode

# Server exposes HTTP streamable transport at:
# http://localhost:3066 (configurable via .env)
```

### Environment Configuration
```bash
MCP_HTTP_HOST=localhost      # Server host
MCP_HTTP_PORT=3066          # Server port  
MCP_SERVER_NAME=AlephCodeAgent
LOG_LEVEL=info              # debug | info | error
```

### MCP Integration
This server implements the full MCP protocol with:
- **Tools**: 25+ functions for CRUD operations on novels/memory structures
- **Resources**: URI-based access to structured data (`aleph://novel/{id}`)
- **Prompts**: Template system for consistent memory operations
- **Auto-persistence**: Automatic saving to `src/resources/novel-data.json`

## Custom Agents

This project includes specialized custom agents for different memory management workflows. Custom agents are defined in `.github/agents/` as `.agent.md` files.

### Editor Agent (`editor.agent.md`)
**Purpose**: Initialize, recover, and manage novel-books (memory containers)
**Use when**: Starting new projects, loading existing memory structures, managing data persistence
**Invoke with**: `@editor` in chat
**Capabilities**:
- Initialize new "novels" (memory projects)
- Recover and validate existing data structures
- Configure auto-save and persistence settings
- Manage server connection and health checks

### Albacea Agent (`albacea.agent.md`) 
**Purpose**: Create and modify elements within novel-books (memory content)
**Use when**: Adding new information, creating relationships, structuring complex data
**Invoke with**: `@albacea` in chat
**Capabilities**:
- Create characters (entities/people/objects to track)
- Create scenes (events/meetings/interactions) 
- Create chapters (project phases/time periods)
- Establish relationships between elements
- Update and modify existing memory structures

### Lector Agent (`lector.agent.md`)
**Purpose**: Query, search, and retrieve information from novel-books
**Use when**: Finding specific information, creating indexes, analyzing stored data
**Invoke with**: `@lector` in chat
**Capabilities**:
- Advanced search across all memory structures
- Generate comprehensive indexes and reports  
- Cross-reference analysis (find all scenes with specific characters)
- Timeline analysis and chronological queries
- Export formatted summaries and documentation

## Memory Structure Patterns

### Novel as Project Container
```javascript
// A "novel" represents a major project or knowledge domain
{
  "title": "Client Project Alpha",
  "author": "Development Team", 
  "genre": ["software", "client-work"],
  "summary": "Complete project memory for Client Alpha engagement",
  "setting": "Remote development environment",
  "characters": ["client-contact-1", "tech-lead", "stakeholder-A"],
  "chapters": ["requirements-phase", "development-phase", "deployment-phase"]
}
```

### Characters as Entities
```javascript
// "Characters" represent people, systems, or important entities
{
  "name": "Sarah Mitchell - Client Technical Lead",
  "description": "Senior developer, primary technical contact",
  "traits": ["detail-oriented", "prefers-email", "available-afternoons"],
  "backstory": "10+ years experience, led similar projects, knows legacy system well"
}
```

### Scenes as Events/Interactions
```javascript
// "Scenes" represent meetings, decisions, or important events
{
  "title": "Requirements Review Meeting",
  "setting": "Zoom call, all stakeholders present",
  "characters": ["sarah-mitchell", "project-manager", "stakeholder-A"],
  "summary": "Finalized core requirements, identified 3 technical risks",
  "content": "Detailed meeting notes, decisions made, action items..."
}
```

### Chapters as Phases/Periods
```javascript
// "Chapters" group related scenes chronologically or thematically
{
  "title": "Development Phase",
  "scenes": ["kickoff-meeting", "tech-review", "mid-sprint-check"],
  "summary": "Active development period with weekly check-ins"
}
```

## Essential Tool Categories

### Discovery & Navigation
- `alephAlpha_listNovels()` - See all memory containers
- `alephAlpha_getNovelDetails(novelId)` - Get complete project overview
- `alephAlpha_listCharacters(novelId?)` - See entities/people
- `alephAlpha_listScenes()` - See all events/interactions

### Content Creation  
- `alephAlpha_createNovel()` - Start new memory container
- `alephAlpha_createCharacter()` - Add person/entity to track
- `alephAlpha_createScene()` - Record event/meeting/interaction
- `alephAlpha_createChapter()` - Group related scenes
- `alephAlpha_createChapterWithScenes()` - Bulk create structured content

### Information Retrieval
- `alephAlpha_getScene(sceneId)` - Get detailed event information
- `alephAlpha_getCharacterDetails(characterId)` - Get entity details
- `alephAlpha_listScenesByNovel(novelId)` - See all events in project
- `alephAlpha_listScenesByChapter(chapterId)` - See events in phase

### Memory Management
- `alephAlpha_saveCurrentState()` - Force save all changes
- `alephAlpha_configureAutoSave(enabled)` - Configure auto-persistence
- `alephAlpha_updateScene()` - Modify existing records
- `alephAlpha_deleteChapter()` - Remove memory structures

## Resource Access Patterns

### URI-based Resource Access
```javascript
// Use resources/read with these URI patterns:
"aleph://novel/{novelId}"           // Complete project data
"aleph://novel/character/{characterId}" // Entity details  
"aleph://novel/scene/{sceneId}"     // Event details
"aleph://server/info"               // Server status
"aleph://resources/index"           // HTML navigation index
```

### Resource Discovery
```javascript
// Always start with resource discovery:
1. resources/list → get available resource types
2. resources/read with specific URIs → get detailed data
3. Use returned IDs for further tool operations
```

## Template System for Consistency

### Memory Operation Templates
The server includes prompt templates for consistent memory operations:
- `novel_start-novel` - Initialize new memory container
- `novel_develop-character` - Create detailed entity profiles
- `novel_plot-development` - Structure complex relationships
- `novel_continue-scene` - Add event details consistently  
- `novel_writing-feedback` - Analyze memory completeness

### Using Templates
```javascript
// Discover available templates
alephAlpha_listNovelistPromptTemplates()

// Get template details
alephAlpha_getNovelistPromptTemplate(templateId)

// Apply with variables
alephAlpha_applyNovelistPromptTemplate(templateId, {
  "project_name": "Client Alpha",
  "context": "Q4 development cycle",
  "key_stakeholders": "Sarah, Mike, Jennifer"
})
```

## Development Workflow Patterns

### Starting a New Memory Project
1. **@editor**: Initialize new novel container
2. **@albacea**: Create key characters (stakeholders/entities)
3. **@albacea**: Create initial scenes (kickoff events)
4. **@editor**: Configure auto-save for continuous updates

### Daily Information Capture
1. **@albacea**: Create scene for each important interaction
2. **@albacea**: Update character details as you learn more
3. **@lector**: Weekly review and index generation

### Project Analysis & Reporting
1. **@lector**: Generate timeline of all interactions
2. **@lector**: Create stakeholder interaction maps
3. **@lector**: Export comprehensive project summaries

### Cross-Project Intelligence  
1. **@lector**: Search across multiple novels for patterns
2. **@lector**: Find common characters across projects
3. **@albacea**: Create new scenes linking related projects

## Error Handling & Troubleshooting

### Connection Issues
- Verify server is running on configured port (default 3066)
- Check HTTP streamable transport compatibility
- Use `aleph://server/info` resource to verify connectivity

### Data Integrity
- Use `alephAlpha_saveCurrentState()` before critical operations  
- Check auto-save status with `alephAlpha_configureAutoSave(true)`
- Monitor `src/resources/novel-data.json` for persistence validation

### Performance Optimization
- Use `resources/list` before `resources/read` for efficiency
- Cache novel IDs and character IDs for repeated operations
- Batch scene creation with `createChapterWithScenes()` when possible

## Integration Examples

### VS Code Extension Integration
```javascript
// Connect to MCP Novelist from VS Code extension
const mcpClient = new MCPClient('http://localhost:3066');

// Store current project context
await mcpClient.callTool('alephAlpha_createScene', {
  title: 'Code Review Session',
  setting: 'VS Code Live Share',
  characters: ['senior-dev', 'junior-dev'],
  summary: 'Reviewed authentication module implementation',
  content: 'Key decisions: use JWT, add rate limiting, update tests'
});
```

### Long-term Project Memory
```javascript
// Retrieve all interactions with specific stakeholder
const scenes = await mcpClient.callTool('alephAlpha_listScenes');
const stakeholderScenes = scenes.filter(scene => 
  scene.characters.includes('client-technical-lead')
);

// Generate comprehensive stakeholder interaction history
const report = stakeholderScenes.map(scene => ({
  date: scene.timestamp,
  context: scene.title,
  summary: scene.summary,
  decisions: extractDecisions(scene.content)
}));
```

## Quality Standards

### Memory Structure Integrity
- **Consistent Naming**: Use descriptive, searchable names for all elements
- **Rich Descriptions**: Include sufficient context in summaries and content
- **Proper Relationships**: Ensure characters appear in relevant scenes
- **Temporal Accuracy**: Maintain chronological order in scene creation

### Information Architecture
- **Logical Grouping**: Use chapters to group related activities/phases
- **Cross-references**: Link related scenes through shared characters
- **Comprehensive Coverage**: Don't leave important interactions unrecorded
- **Regular Maintenance**: Update character details as relationships evolve

### Documentation Standards
- **Searchable Content**: Write summaries and content with future queries in mind
- **Consistent Terminology**: Use standardized terms across all memory structures
- **Context Preservation**: Include enough detail to understand decisions later
- **Actionable Information**: Record not just what happened, but why and what's next

Remember: You're not writing literature - you're creating a sophisticated, searchable, long-term memory system that happens to use novel-like structures for optimal organization and retrieval of complex information and relationships.