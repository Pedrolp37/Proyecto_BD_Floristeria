document.addEventListener('DOMContentLoaded', () => {
    const floristeriaFilter = document.getElementById('floristeriaFilter');
    const fechaFilter = document.getElementById('fechaFilter');
    const facturaContainer = document.getElementById('facturaContainer');

    // Fetch para obtener las floristerias
    fetch('/floristerias')
        .then(response => response.json())
        .then(data => {
            data.forEach(floris => {
                const optionElement = document.createElement('option');
                optionElement.value = floris.id_floristeria;
                optionElement.textContent = floris.nombre;
                floristeriaFilter.appendChild(optionElement);
            });
        })
        .catch(error => console.error('Error al obtener las floristerias:', error));

    // Evento para cuando se selecciona una floristeria
    floristeriaFilter.addEventListener('change', () => {
        const selectedFloristeria = floristeriaFilter.value;
        
        if (selectedFloristeria) {
            fetchFechasFacturas(selectedFloristeria);
        } else {
            // Limpiar el selector de fechas si no hay floristeria seleccionada
            fechaFilter.innerHTML = '<option value="">Seleccionar Fecha</option>';
        }
        clearFacturas(); // Limpiar las facturas mostradas al cambiar la floristería
    });

    // Evento para obtener las facturas basadas en la fecha seleccionada
    fechaFilter.addEventListener('change', () => {
        const selectedFecha = fechaFilter.value;

        if (selectedFecha) {
            fetchFacturaYlote(selectedFecha);
        } else {
            clearFacturas(); // Limpiar las facturas si no hay fecha seleccionada
        }
    });

    // Función para hacer fetch de las fechas de facturas basadas en la floristeria seleccionada
    function fetchFechasFacturas(floristeriaId) {
        fetch(`/fechas-facturas/${floristeriaId}`)
            .then(response => response.json())
            .then(data => {
                fechaFilter.innerHTML = '<option value="">Seleccionar Fecha</option>'; // Limpiar opciones de fecha
                data.forEach(fecha => {
                    const optionElement = document.createElement('option');
                    optionElement.value = fecha.cod_fac_sub; // Usar el identificador único
                    optionElement.textContent = fecha.fecha_factura;
                    fechaFilter.appendChild(optionElement);
                });
            })
            .catch(error => console.error('Error al obtener las fechas de facturas:', error));
    }

    // Función para hacer fetch de una factura y su lote por ID de factura
    function fetchFacturaYlote(facturaId) {
        fetch(`/factura/${facturaId}`)
            .then(response => response.json())
            .then(facturaData => {
                // Convertir precio_total a número
                const precioTotal = parseFloat(facturaData.precio_total) || 0;
    
                const fechaFormateada = formatDate(facturaData.fecha_factura);
                // Hacer fetch del lote usando el ID de la factura
                fetch(`/lote/${facturaId}`)
                    .then(response => response.json())
                    .then(loteData => {
                        // Tomar el primer productor
                        const primerProductor = loteData.length ? loteData[0].nombre_productor : 'Desconocido';
    
                        // Sumar todos los precio_final de los lotes
                        const totalPrecioLotes = loteData.reduce((sum, lote) => sum + (parseFloat(lote.precio_final) || 0), 0);
    
                        // Calcular el importe por envío
                        const importeEnvio = precioTotal - totalPrecioLotes;
    
                        // Actualizar el contenido del contenedor de facturas
                        facturaContainer.innerHTML = `
                            <div class="factura-item">
                                <p><strong>Nombre Subastadora:</strong> ${facturaData.nombre_subas}</p>
                                <p><strong>Direccion Principal:</strong> ${facturaData.direccion_pppal}</p>
                                <p><strong>Productor:</strong> ${primerProductor}</p>
                                <p>:</strong>-------------------------------------</p>
                                <p><strong>ID Factura:</strong> ${facturaData.cod_fac_sub}</p>
                                <p><strong>Fecha:</strong> ${fechaFormateada}</p>
                                <p>:</strong>-------------------------------------</p>
                            </div>
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID Lote</th>
                                        <th>Nombre Flor</th>
                                        <th>Cantidad</th>
                                        <th>Precio Lote</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    ${loteData.map(lote => `
                                        <tr>
                                            <td>${lote.numerolote}</td>
                                            <td>${lote.nombre_flor_pro}</td>
                                            <td>${lote.cantidad_lote}</td>
                                            <td>${lote.precio_final}</td>
                                        </tr>
                                    `).join('')}
                                </tbody>
                            </table>
                            <p>:</strong>--------------------------------------------------------------------------</p>
                             <p><strong>Total Precio Lotes:</strong> ${totalPrecioLotes.toFixed(2)}</p>
                             <p><strong>Importe por Envío:</strong> ${importeEnvio.toFixed(2)}</p>
                            <p><strong>Total Final:</strong> ${precioTotal}</p>
                           
                        `;
                    })
                    .catch(error => console.error('Error al obtener el lote:', error));
            })
            .catch(error => console.error('Error al obtener la factura:', error));
    }
    
// Función para formatear la fecha a 'YYYY-MM-DD' 
function formatDate(dateString) {
     const date = new Date(dateString); 
     const year = date.getFullYear(); 
     const month = String(date.getMonth() + 1).padStart(2, '0'); 
     const day = String(date.getDate()).padStart(2, '0');
     return `${year}-${month}-${day}`;
     }

    // Función para limpiar las facturas mostradas
    function clearFacturas() {
        facturaContainer.innerHTML = '';
    }
});

