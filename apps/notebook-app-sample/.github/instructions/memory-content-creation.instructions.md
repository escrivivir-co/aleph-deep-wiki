# Memory Content Creation Instructions

## Overview
This guide provides detailed instructions for creating and structuring memory content within novel-books using the MCP Novelist server. Focus on transforming raw information into searchable, interconnected memory elements.

## Prerequisites
- Initialized memory container (novel-book) from memory-initialization process
- Access to MCP tools in VS Code Copilot Chat
- Understanding of the novel-as-memory-container metaphor

## Core Content Types

### Characters as Entities
**Purpose**: Track people, systems, tools, or any important entities across memory structures
**Use Cases**: Stakeholders, team members, external systems, tools, clients, vendors

### Scenes as Events/Interactions
**Purpose**: Record meetings, decisions, interactions, or significant events
**Use Cases**: Meetings, decisions, incidents, milestones, learning moments

### Chapters as Phases/Periods
**Purpose**: Group related scenes chronologically or thematically
**Use Cases**: Project phases, time periods, functional areas, workflows

## Character (Entity) Creation Guidelines

### People as Characters
```javascript
alephAlpha_createCharacter({
  name: "Sarah Mitchell - Client Technical Lead",
  description: "Senior developer with 10+ years experience, primary technical contact for Project Alpha",
  traits: [
    "detail-oriented",
    "prefers-email-communication", 
    "available-afternoons-EST",
    "expertise-legacy-systems"
  ],
  backstory: "Led 3 similar integration projects. Knows legacy system architecture. Prefers technical documentation over meetings. Has final approval on technical decisions.",
  novelId: "project-alpha-memory"
})
```

### Systems as Characters
```javascript
alephAlpha_createCharacter({
  name: "Legacy Payment API",
  description: "External payment processing system, REST-based, requires OAuth 2.0",
  traits: [
    "rate-limited-1000-requests-hour",
    "downtime-sundays-2am-4am",
    "requires-ip-whitelisting",
    "supports-webhooks"
  ],
  backstory: "Implemented in 2019. Previous integration challenges with rate limiting. Documentation incomplete but stable performance. Contact: api-support@client.com",
  novelId: "project-alpha-memory"
})
```

### Tools/Services as Characters
```javascript
alephAlpha_createCharacter({
  name: "Jenkins CI/CD Pipeline",
  description: "Continuous integration and deployment system for Project Alpha",
  traits: [
    "builds-every-commit",
    "deploys-to-staging-automatically",
    "requires-manual-production-approval",
    "slack-notifications-enabled"
  ],
  backstory: "Configured Q3 2024. Initial setup by DevOps team. Current maintainer: Mike Johnson. Build time: 8-12 minutes. Occasional timeout issues on large deployments.",
  novelId: "project-alpha-memory"
})
```

## Scene (Event) Creation Guidelines

### Meeting Scenes
```javascript
alephAlpha_createScene({
  title: "Sprint Planning #5 - Database Schema Review",
  setting: "Zoom call, all core team members present, 2-hour session",
  characters: ["sarah-mitchell", "mike-johnson-devops", "lisa-chen-qa", "project-manager"],
  summary: "Reviewed database schema changes for user authentication. Identified 2 migration concerns. Decided on phased rollout approach.",
  content: `
# Key Decisions:
- Use staged migration approach (test → staging → production)
- Backup database before each migration step
- Schedule migrations for low-traffic windows (2-4 AM EST)

# Action Items:
- Mike: Prepare migration scripts by Friday
- Lisa: Design rollback test scenarios
- Sarah: Review security implications of schema changes

# Concerns Raised:
- Potential downtime during migration (estimated 30-45 minutes)
- Need for communication plan to stakeholders
- Rollback complexity if issues arise

# Next Meeting: Thursday 2 PM EST - Migration preparation review
  `,
  novelId: "project-alpha-memory"
})
```

### Decision Scenes
```javascript
alephAlpha_createScene({
  title: "Architecture Decision: Message Queue Selection",
  setting: "Technical architecture review, senior developers only",
  characters: ["sarah-mitchell", "mike-johnson-devops", "technical-architect"],
  summary: "Evaluated RabbitMQ vs Apache Kafka for async processing. Selected RabbitMQ based on team expertise and project scale.",
  content: `
# Decision: RabbitMQ Selected for Message Processing

## Evaluation Criteria:
- Team expertise and learning curve
- Operational complexity
- Performance requirements
- Cost considerations

## Options Considered:
1. **RabbitMQ**: Familiar to team, simpler ops, sufficient performance
2. **Apache Kafka**: Higher performance, more complex, steeper learning curve
3. **AWS SQS**: Cloud-native, vendor lock-in concerns

## Final Decision: RabbitMQ
**Reasoning**: Team has 2 years experience with RabbitMQ. Current scale (< 10k messages/hour) well within capabilities. Can migrate to Kafka later if needed.

## Implementation Plan:
- Week 1: Set up RabbitMQ cluster in staging
- Week 2: Implement message producers/consumers
- Week 3: Load testing and monitoring setup
- Week 4: Production deployment

## Success Metrics:
- Message processing latency < 100ms p95
- Zero message loss
- 99.9% availability
  `,
  novelId: "project-alpha-memory"
})
```

### Incident/Learning Scenes
```javascript
alephAlpha_createScene({
  title: "Production Incident: Database Connection Pool Exhaustion",
  setting: "Emergency response, war room setup via Slack + Zoom",
  characters: ["mike-johnson-devops", "database-admin", "on-call-engineer"],
  summary: "Database connection pool exhausted causing 503 errors. Resolved by increasing pool size and implementing connection monitoring.",
  content: `
# Incident Timeline:
- 14:30 EST: First 503 errors reported
- 14:32 EST: On-call engineer paged
- 14:35 EST: War room established
- 14:45 EST: Root cause identified (connection pool exhaustion)
- 15:00 EST: Temporary fix applied (increased pool size)
- 15:15 EST: Service fully restored

# Root Cause:
Gradual increase in database connections over past week. Connection pool size (50) insufficient for current load (estimated 75-80 concurrent connections needed).

# Resolution:
- Immediate: Increased connection pool size from 50 to 100
- Short-term: Implemented connection pool monitoring with alerts
- Long-term: Review connection usage patterns, implement connection pooling best practices

# Lessons Learned:
- Need proactive monitoring of connection pool usage
- Connection pool sizing should account for growth
- Consider connection timeout and cleanup strategies

# Action Items:
- Mike: Implement connection pool monitoring (due: next sprint)
- DBA: Review all application connection patterns (due: 2 weeks)
- Team: Document incident response procedures (due: 1 week)
  `,
  novelId: "project-alpha-memory"
})
```

## Chapter (Phase) Creation Guidelines

### Project Phase Chapters
```javascript
alephAlpha_createChapter({
  title: "Requirements Gathering Phase",
  scenes: [
    "initial-client-meeting",
    "stakeholder-interviews", 
    "technical-requirements-review",
    "scope-finalization-meeting"
  ],
  summary: "Complete requirements gathering including stakeholder interviews, technical analysis, and scope definition. Resulted in detailed project specification and timeline.",
  novelId: "project-alpha-memory"
})
```

### Bulk Chapter Creation with Scenes
```javascript
alephAlpha_createChapterWithScenes({
  novelId: "project-alpha-memory",
  chapterTitle: "Development Sprint 1",
  chapterSummary: "First development sprint focusing on authentication system implementation",
  sceneDescriptions: [
    {
      title: "Sprint 1 Planning",
      setting: "Team planning room, 2-hour session",
      summary: "Planned authentication system implementation, estimated 3 weeks",
      characterIds: ["sarah-mitchell", "frontend-lead", "backend-lead"]
    },
    {
      title: "OAuth 2.0 Integration Research",
      setting: "Technical research session",
      summary: "Investigated OAuth 2.0 implementation options and client requirements",
      characterIds: ["backend-lead", "security-consultant"]
    },
    {
      title: "Database Schema Design",
      setting: "Architecture review meeting",
      summary: "Designed user authentication tables and security considerations",
      characterIds: ["database-admin", "backend-lead", "sarah-mitchell"]
    }
  ]
})
```

## Content Quality Standards

### Character (Entity) Quality
- **Descriptive Names**: Include role/context in name for searchability
- **Rich Traits**: Include behavioral patterns, preferences, constraints
- **Comprehensive Backstory**: Provide context for future decision-making
- **Searchable Content**: Use terms that will be relevant for future queries

### Scene (Event) Quality
- **Clear Titles**: Descriptive titles that indicate type and scope
- **Detailed Setting**: Provide context about environment and participants
- **Actionable Content**: Include decisions, action items, next steps
- **Future Context**: Write for someone discovering this information later

### Chapter (Phase) Quality
- **Logical Grouping**: Group related scenes that belong together
- **Clear Summaries**: Explain what was accomplished in this phase
- **Temporal Accuracy**: Maintain chronological organization
- **Complete Coverage**: Don't leave gaps in important sequences

## Content Relationships and Cross-references

### Character-Scene Relationships
- Ensure characters appear in all relevant scenes
- Track character evolution across scenes
- Document changing roles and responsibilities

### Scene-Chapter Organization
- Group scenes logically into phases or themes
- Maintain chronological flow within chapters
- Ensure chapter summaries accurately reflect contained scenes

## Updating and Maintenance

### Scene Updates
```javascript
alephAlpha_updateScene(sceneId, {
  content: "Additional information discovered later...",
  characters: ["original-participant", "newly-added-participant"],
  summary: "Updated summary with new insights..."
})
```

### Content Enhancement
Regularly enhance content with:
- Additional context discovered later
- Outcome updates for decisions
- Lessons learned from implementation
- Cross-references to related events

## Integration Workflows

### From Memory Initialization
After Editor mode creates container:
1. Create foundational characters (key stakeholders)
2. Record initial scenes (kickoff events)
3. Establish chapter structure (project phases)

### To Information Retrieval
Prepare content for Lector mode analysis:
- Use consistent naming conventions
- Include rich, searchable content
- Maintain proper relationships
- Document temporal sequences

## Troubleshooting Content Creation

### Character Creation Issues
- Verify novelId exists if specified
- Ensure name uniqueness within project
- Check that traits array contains strings
- Validate backstory provides sufficient context

### Scene Creation Issues
- Verify character IDs exist before referencing
- Ensure setting provides clear context
- Check that summary is descriptive enough
- Validate content includes actionable information

### Chapter Organization Issues
- Verify scene IDs exist before grouping
- Ensure logical grouping of related scenes
- Check chronological ordering within chapters
- Validate chapter summaries accurately represent content