- Logs
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker logs deepwiki_wiki


- reiniciar el contenedor de la wiki:
docker-compose -f docker-compose.external-ollama.yml down -d wiki
docker-compose -f docker-compose.external-ollama.yml up -d wiki


docker logs deepwiki_chroma