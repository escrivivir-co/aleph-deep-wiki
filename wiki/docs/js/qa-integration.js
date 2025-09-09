// Q&A Integration JavaScript for DeepWiki

document.addEventListener('DOMContentLoaded', function() {
    console.log('DeepWiki Q&A Integration loaded');
    
    // API Configuration - Fixed URL definition
    window.QA_API_URL = 'http://localhost:5000';
    const QA_API_URL = window.QA_API_URL;
    
    // Add Q&A interface to repository pages
    if (window.location.pathname.includes('/repos/')) {
        addQAInterface();
    }
    
    // Check API health on load
    checkAPIHealth();
});

function addQAInterface() {
    const content = document.querySelector('.md-content');
    if (!content) return;
    
    const qaContainer = document.createElement('div');
    qaContainer.innerHTML = `
        <div class="qa-container">
            <h3>🤖 Pregunta sobre este repositorio</h3>
            <p>Usa inteligencia artificial para consultar sobre el código de este repositorio:</p>
            <input type="text" class="qa-input" id="qa-question" placeholder="Ej: ¿Qué hace este repositorio? ¿Cuáles son los archivos principales?">
            <button class="qa-button" onclick="askQuestion()">Preguntar</button>
            <div class="qa-response" id="qa-response" style="display: none;">
                <div id="qa-answer"></div>
            </div>
        </div>
    `;
    
    // Insert after the first h1
    const firstH1 = content.querySelector('h1');
    if (firstH1) {
        firstH1.parentNode.insertBefore(qaContainer, firstH1.nextSibling);
    }
}

async function askQuestion() {
    const questionInput = document.getElementById('qa-question');
    const responseDiv = document.getElementById('qa-response');
    const answerDiv = document.getElementById('qa-answer');
    
    const question = questionInput.value.trim();
    if (!question) {
        alert('Por favor escribe una pregunta');
        return;
    }
    
    // Show loading
    responseDiv.style.display = 'block';
    answerDiv.innerHTML = '<div class="qa-loading">🤔 Pensando...</div>';
    
    try {
        // Use the global API URL
        const API_URL = window.QA_API_URL || 'http://localhost:5000';
        
        // Extract repo name from URL
        const pathParts = window.location.pathname.split('/');
        const repoName = pathParts[pathParts.length - 1].replace('.md', '').replace('/', '');
        
        const response = await fetch(`${API_URL}/ask`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                question: question,
                repo_filter: repoName,
                model: 'gpt-oss:20b'
            })
        });
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        const data = await response.json();
        
        // Display answer
        answerDiv.innerHTML = `
            <h4>💡 Respuesta:</h4>
            <p>${data.answer}</p>
            <details style="margin-top: 15px;">
                <summary>🔍 Fuentes utilizadas</summary>
                <ul>
                    ${data.sources.map(source => `
                        <li><code>${source.file}</code> (${source.relevance})</li>
                    `).join('')}
                </ul>
            </details>
        `;
        
    } catch (error) {
        console.error('Error asking question:', error);
        answerDiv.innerHTML = `
            <div style="color: #d32f2f;">
                <h4>❌ Error</h4>
                <p>No se pudo procesar la pregunta: ${error.message}</p>
                <p>Asegúrate de que el servicio Q&A esté funcionando en ${API_URL}</p>
            </div>
        `;
    }
}

async function checkAPIHealth() {
    try {
        const API_URL = window.QA_API_URL || 'http://localhost:5000';
        
        // Primero intentar con CORS normal
        let response;
        try {
            response = await fetch(`${API_URL}/health`);
        } catch (corsError) {
            console.log('CORS error, trying no-cors mode:', corsError.message);
            // Si falla CORS, intentar con no-cors
            response = await fetch(`${API_URL}/health`, { 
                mode: 'no-cors',
                method: 'GET'
            });
        }
        
        // Con no-cors no podemos leer la respuesta, pero si llega aquí significa que la API está disponible
        if (response.type === 'opaque') {
            console.log('Q&A API available (no-cors mode)');
            addStatusIndicator('🟡 Q&A API: Disponible (no-cors)', 'warning');
            return true;
        }
        
        // Si llegamos aquí con respuesta normal, procesarla
        if (response.ok) {
            const health = await response.json();
            console.log('Q&A API Status:', health);
            
            // Add status indicator to page
            if (health.status === 'healthy') {
                addStatusIndicator('🟢 Q&A API: Operativo', 'success');
                return true;
            }
        }
        
        return false;
        
    } catch (error) {
        console.log('Q&A API not available:', error.message);
        addStatusIndicator('🔴 Q&A API: No disponible', 'error');
        return false;
    }
}

function addStatusIndicator(text, type) {
    const indicator = document.createElement('div');
    indicator.className = `api-status status-${type}`;
    indicator.style.cssText = `
        position: fixed;
        top: 10px;
        right: 10px;
        background: ${type === 'success' ? '#e8f5e8' : '#ffebee'};
        color: ${type === 'success' ? '#2e7d32' : '#c62828'};
        padding: 8px 12px;
        border-radius: 4px;
        font-size: 12px;
        z-index: 1000;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    `;
    indicator.textContent = text;
    document.body.appendChild(indicator);
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
        if (indicator.parentNode) {
            indicator.parentNode.removeChild(indicator);
        }
    }, 5000);
}
