docker-compose -f docker-compose.external-ollama.yml down -d wiki
sleep 3 && docker logs deepwiki_wiki
docker-compose -f docker-compose.external-ollama.yml restart wiki
sleep 3 && docker logs deepwiki_wiki
