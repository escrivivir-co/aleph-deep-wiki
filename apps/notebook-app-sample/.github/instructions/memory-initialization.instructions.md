# Memory Container Initialization Instructions

## Overview
This guide provides detailed instructions for initializing new memory containers (novel-books) in the MCP Novelist server. Use these instructions when setting up long-term memory storage for projects, research, or complex information management.

## Prerequisites
- MCP Novelist server running on localhost:3066 (or configured port)
- Access to MCP tools in VS Code Copilot Chat
- Understanding that "novels" are memory containers, not creative writing projects

## Step-by-Step Initialization Process

### 1. Server Health Verification
Before creating new memory containers, verify server connectivity:

```javascript
// Check server status
resources/read "aleph://server/info"

// Verify available resources
resources/list
```

**Expected Response**: Server info with MCP capabilities and available resource types.

### 2. Assess Memory Requirements
Determine the type of information that needs long-term storage:

- **Project Memory**: Client work, development projects, research initiatives
- **Stakeholder Networks**: People, systems, and entity relationships
- **Decision History**: Important choices, their context, and outcomes
- **Knowledge Base**: Technical learnings, process documentation, best practices

### 3. Initialize Memory Container
Create the novel-book container with appropriate metadata:

```javascript
alephAlpha_createNovel({
  title: "Descriptive Project Name",
  author: "Team or Individual Name", 
  genre: ["project-type", "domain", "context"],
  summary: "Clear description of what this memory contains",
  setting: "Environment or context where this information exists"
})
```

**Naming Conventions**:
- **Title**: Clear, searchable project identifiers
- **Genre**: Use tags like ["client-work", "internal-project", "research", "learning"]
- **Summary**: Write for future discoverability
- **Setting**: Context that helps understand the environment

### 4. Configure Auto-Persistence
Ensure automatic saving is enabled for continuous memory capture:

```javascript
alephAlpha_configureAutoSave(true)
```

### 5. Validation and Handoff
Verify the container was created successfully:

```javascript
// List all containers to confirm creation
alephAlpha_listNovels()

// Get detailed view of new container
alephAlpha_getNovelDetails(novelId)

// Force initial save
alephAlpha_saveCurrentState()
```

## Configuration Best Practices

### Memory Container Naming
- Use descriptive, searchable titles
- Include timeframes when relevant: "Q4 2024 Client Alpha"
- Avoid generic names: use "OAuth Migration Project" not "New Project"

### Genre Tagging Strategy
Establish consistent tagging patterns:
- **By Type**: "client-work", "internal-project", "research", "learning"
- **By Domain**: "backend", "frontend", "infrastructure", "compliance"
- **By Status**: "active", "completed", "archived", "planning"

### Summary Guidelines
Write summaries that answer:
- What type of information is stored here?
- What was the context or purpose?
- Who are the key stakeholders?
- What timeframe does this cover?

## Example Initialization Scenarios

### Client Project Memory
```javascript
alephAlpha_createNovel({
  title: "Acme Corp API Integration - Q4 2024",
  author: "Development Team Alpha",
  genre: ["client-work", "api-integration", "active"],
  summary: "Complete project memory for Acme Corp's payment API integration, including stakeholder meetings, technical decisions, and implementation progress",
  setting: "Remote development environment with weekly client check-ins"
})
```

### Research Knowledge Base
```javascript
alephAlpha_createNovel({
  title: "Machine Learning Implementation Research",
  author: "R&D Team",
  genre: ["research", "machine-learning", "internal-project"],
  summary: "Research findings, vendor evaluations, and technical experiments for ML capabilities integration",
  setting: "6-month research initiative with external consultants"
})
```

### Team Process Documentation
```javascript
alephAlpha_createNovel({
  title: "Development Process Evolution 2024",
  author: "Engineering Leadership",
  genre: ["process-documentation", "team-management", "internal"],
  summary: "Documentation of process changes, team retrospectives, and workflow optimizations throughout 2024",
  setting: "Agile development team with quarterly process reviews"
})
```

## Troubleshooting Common Issues

### Server Connection Problems
- Verify server is running: `npm run dev` in mcp-novelist directory
- Check port configuration in .env file (default: 3066)
- Confirm HTTP streamable transport is accessible

### Auto-Save Configuration
- Always enable auto-save after container creation
- Monitor `src/resources/novel-data.json` for persistence validation
- Use manual save before critical operations

### Container Structure Validation
- Use `resources/read "aleph://novel/{novelId}"` to verify structure
- Check that all required fields are populated
- Validate that the container appears in `alephAlpha_listNovels()`

## Next Steps After Initialization

1. **Character Creation**: Add key stakeholders, systems, and entities
2. **Initial Scene Recording**: Capture kickoff events or foundational information
3. **Chapter Planning**: Organize information into logical phases or categories
4. **Template Configuration**: Set up prompt templates for consistent content creation

## Integration with Other Workflows

### Handoff to Content Creation (Albacea Mode)
After successful initialization, transition to content creation:
- "Memory container '{title}' initialized successfully"
- "Ready for character and scene creation"
- "Auto-save enabled, persistence validated"

### Connection to Analysis (Lector Mode)
Prepare for future information retrieval:
- Establish searchable naming conventions
- Create clear category structures
- Document initialization decisions for future reference