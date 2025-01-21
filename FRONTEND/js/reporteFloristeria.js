document.addEventListener('DOMContentLoaded', () => {
    const dataTable = document.getElementById('dataTable').getElementsByTagName('tbody')[0];
    const floristeriaFilter = document.getElementById('floristeriaFilter');
    const searchInput = document.getElementById('searchInput');
    const tipoFilter = document.getElementById('tipoFilter');
    const colorFilter = document.getElementById('colorFilter');
    const dateFilter = document.getElementById('dateFilter');

    let floresData = []; // Array para almacenar los datos completos de las flores

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
            fetch(`/flores-floristeria/${selectedFloristeria}`)
                .then(response => response.json())
                .then(data => {
                    floresData = data;
                    populateTable(floresData);
                    populateFilters(floresData);
                })
                .catch(error => console.error('Error al obtener las flores de la floristeria:', error));
        } else {
            clearTableAndFilters(); // Limpiar tabla y filtros si no hay floristeria seleccionada
        }
    });

    // Eventos para filtrar las flores basados en los selectores
    tipoFilter.addEventListener('change', applyFilters);
    colorFilter.addEventListener('change', applyFilters);
    searchInput.addEventListener('input', applyFilters);
    dateFilter.addEventListener('change', applyFilters);

    // Función para aplicar filtros
    function applyFilters() {
        const searchText = searchInput.value.toLowerCase();
        const selectedTipo = tipoFilter.value;
        const selectedColor = colorFilter.value;
        const selectedDate = dateFilter.value || new Date().toISOString().split('T')[0]; // Utiliza la fecha actual si no se selecciona una fecha

        fetchPriceForDate(selectedDate)
            .then(priceData => {
                const filteredData = floresData.filter(flor => {
                    return (selectedTipo === '' || flor.flor_genero_especie === selectedTipo) &&
                           (selectedColor === '' || flor.color_nombre === selectedColor) &&
                           (searchText === '' || flor.flor_nombre.toLowerCase().includes(searchText));
                }).map(flor => {
                    return {...flor, precio_historico: priceData[flor.cf_id] || null};
                });

                populateTable(filteredData);
            })
            .catch(error => console.error('Error al obtener los precios más cercanos:', error));
    }

    // Función para hacer fetch del precio más cercano
    function fetchPriceForDate(date) {
        return fetch(`/historico-precio?date=${date}`)
            .then(response => response.json())
            .then(data => {
                const priceMap = {};
                data.forEach(record => {
                    priceMap[record.cf_id] = record.precio_hist;
                });
                return priceMap;
            })
            .catch(error => {
                console.error('Error al obtener el precio del histórico:', error);
                return {};
            });
    }

    // Función para poblar la tabla
    function populateTable(data) {
        dataTable.innerHTML = ''; // Limpiar la tabla
        data.forEach(flor => {
            const row = dataTable.insertRow();
            const nombreCell = row.insertCell(0);
            const promedioCell = row.insertCell(1);
            const generoEspecieCell = row.insertCell(2);
            const actionCell = row.insertCell(3);

            nombreCell.textContent = flor.flor_nombre;

            const promedioVenta = parseFloat(flor.promedio_venta) || 0;
            promedioCell.textContent = promedioVenta; // Mantener promedio_venta
            generoEspecieCell.textContent = flor.flor_genero_especie;

            const detailButton = document.createElement('button');
            detailButton.textContent = 'Ver Detalle';
            detailButton.onclick = () => {
                const url = `detalleFlorFloris.html?id=${flor.cf_id}`;
                if (flor.precio_historico) {
                    url += `&precio=${flor.precio_historico}`;
                }
                window.location.href = url;
            };
            actionCell.appendChild(detailButton);
        });
    }

    // Función para poblar los filtros
    function populateFilters(data) {
        // Limpiar filtros
        tipoFilter.innerHTML = '<option value="">Tipo de Flor</option>';
        colorFilter.innerHTML = '<option value="">Escoger Color</option>';

        // Crear sets para tipos y colores únicos
        const tipos = new Set();
        const colores = new Set();

        // Poblar sets con datos únicos
        data.forEach(flor => {
            tipos.add(flor.flor_genero_especie);
            colores.add(flor.color_nombre);
        });

        // Agregar opciones únicas a los filtros
        tipos.forEach(tipo => {
            const optionElement = document.createElement('option');
            optionElement.value = tipo;
            optionElement.textContent = tipo;
            tipoFilter.appendChild(optionElement);
        });

        colores.forEach(color => {
            const optionElement = document.createElement('option');
            optionElement.value = color;
            optionElement.textContent = color;
            colorFilter.appendChild(optionElement);
        });
    }

    // Función para limpiar tabla y filtros
    function clearTableAndFilters() {
        dataTable.innerHTML = ''; // Limpiar la tabla
        tipoFilter.innerHTML = '<option value="">Tipo de Flor</option>'; // Limpiar opciones de tipo de flor
        colorFilter.innerHTML = '<option value="">Escoger Color</option>'; // Limpiar opciones de color
    }
});