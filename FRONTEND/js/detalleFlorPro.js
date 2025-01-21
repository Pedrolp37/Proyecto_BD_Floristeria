document.addEventListener('DOMContentLoaded', () => {
    const florDetail = document.getElementById('florDetail');
    const urlParams = new URLSearchParams(window.location.search);
    const florId = urlParams.get('id');

    if (florId) {
        fetch(`/flor-productor/${florId}`)
            .then(response => response.json())
            .then(data => {
                displayFlorDetail(data);
            })
            .catch(error => console.error('Error al obtener la flor:', error));
    } else {
        florDetail.innerHTML = '<p>No se ha especificado una flor.</p>';
    }

    // Función para mostrar la información detallada
    function displayFlorDetail(flor) {
        florDetail.innerHTML = `
            <h1>${flor.nombre_comun}</h1>
           
            <div class="info-group">
                <label>Genero:</label>
                <span>${flor.genero_especie}</span>
            </div>
             <div class="info-group">
                <label>Etimologia:</label>
                <span>${flor.etimologia}</span>
            </div>
            <div class="info-group">
                <label>Colores:</label>
                <span>${flor.colores}</span>
            </div>
             <div class="info-group">
                <label>Temperatura:</label>
                <span>${flor.temperatura}</span>
            </div>
            <!-- Agrega más información según sea necesario -->
        `;
    }
});
