document.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    const cfId = urlParams.get('id');

    if (cfId) {
        fetchCatalogAndHistoricoInfo(cfId);
        fetchBouquetInfo(cfId);
    }

    function fetchCatalogAndHistoricoInfo(cfId) {
        fetch(`/catalogo-floristeria/${cfId}`)
            .then(response => response.json())
            .then(data => {
                const catalogInfo = document.getElementById('catalogInfo');
                catalogInfo.innerHTML = `
                    <p><strong>Nombre:</strong> ${data.nombre}</p>
                    <p><strong>Descripción:</strong> ${data.descripcion}</p>
                    <p><strong>Precio Histórico:</strong> ${parseFloat(data.precio_hist).toFixed(2)}</p>
                    <p><strong>Tamaño Tallo:</strong> ${data.tamano_tallo}</p>
                `;
            })
            .catch(error => console.error('Error al obtener la información del catálogo y histórico de precios:', error));
    }

    function fetchBouquetInfo(cfId) {
        fetch(`/det-bouquet/${cfId}`)
            .then(response => response.json())
            .then(data => {
                const bouquetInfo = document.getElementById('bouquetInfo');
                bouquetInfo.innerHTML = data.map(bouquet => `
                    <div class="bouquet-item">
                        <p><strong>ID Bouquet:</strong> ${bouquet.id_bouquet}</p>
                        <p><strong>Cantidad:</strong> ${bouquet.cantidad}</p>
                        <p><strong>Precio:</strong> ${(bouquet.cantidad * bouquet.precio_hist).toFixed(2)}</p>
                        <p><strong>Tamaño Tallo:</strong> ${bouquet.tallo_tamano}</p>
                        <p><strong>Descripción:</strong> ${bouquet.descripcion}</p>
                    </div>
                `).join('');
            })
            .catch(error => console.error('Error al obtener los detalles del bouquet:', error));
    }
});
