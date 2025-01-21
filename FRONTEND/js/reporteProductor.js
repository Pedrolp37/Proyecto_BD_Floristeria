document.addEventListener('DOMContentLoaded', () => {
    const cardContainer = document.getElementById('productorContainer');
    const productorFilter = document.getElementById('productorFilter');
    const tipoFlorProductor = document.getElementById('tipoFlorProductor');

    // Fetch para obtener los productores
    fetch('/productores')
        .then(response => {
            if (!response.ok) {
                throw new Error('Error al obtener los productores');
            }
            return response.json();
        })
        .then(data => {
            data.forEach(productor => {
                const optionElement = document.createElement('option');
                optionElement.value = productor.id_productor;
                optionElement.textContent = productor.nombre_productor;
                productorFilter.appendChild(optionElement);
            });
        })
        .catch(error => console.error('Error al obtener los productores:', error));

    // Evento para filtrar las tarjetas
    productorFilter.addEventListener('change', () => {
        const selectedValue = productorFilter.value;
        if (selectedValue) {
             // Hacer fetch para obtener los tipo de flor asociadas al productor seleccionado el select de tipo flor
             fetch(`/productor/tipo-flor/${selectedValue}`)
             .then(response => response.json())
             .then(data => {
                tipoFlorProductor.innerHTML = '<option value="">Todos</option>';
                // Limpiar opciones anteriores
                 data.forEach(tipoFlor => {
                  const optionElement = document.createElement('option');
                  optionElement.value = tipoFlor.id_corte;
                  optionElement.textContent = tipoFlor.nombre_comun;
                  tipoFlorProductor.appendChild(optionElement);
                 });

            // Hacer fetch para obtener las flores del productor seleccionado
            fetch(`/flores-productor/${selectedValue}`)
                .then(response => response.json())
                .then(data => {
                    populateCards(data);
                })
                .catch(error => console.error('Error al obtener las flores del productor:', error));
              });


        } else {
            cardContainer.innerHTML = ''; // Limpiar el contenedor si no hay productor seleccionado
        }
    });

// Evento para filtrar las tarjetas por tipo de flor
    tipoFlorProductor.addEventListener('change', () => {
      const productorValue = productorFilter.value;
      const tipoFlorValue = tipoFlorProductor.value;
        if (productorValue) {
          let url = `/flores-productor/${productorValue}`;
          if (tipoFlorValue) { 
            url += `/tipo/${tipoFlorValue}`;
          }
          fetch(url)
            .then(response => response.json())
            .then(data => { 
              populateCards(data);
            }) 
            .catch(error => console.error('Error al obtener las flores filtradas:', error));
            } else {
              cardContainer.innerHTML = ''; // Limpiar el contenedor si no hay productor seleccionado
            } 
    });

    // Función para poblar las tarjetas
    function populateCards(data) {
        cardContainer.innerHTML = ''; // Limpiar el contenedor de tarjetas
        data.forEach(flor => {
            const card = document.createElement('a');
            card.className = 'card';
            card.href = `detalleFlorPro.html?id=${flor.codigo_vbn}`;
            card.innerHTML = `
              <div class="card-content">
                <img src="/images/${flor.logo_flor}" alt="Logo de la Flor">
                <h2>${flor.nombre_flor_pro}</h2>
                <p>Código VBN N°: ${flor.codigo_vbn}</p>
                <p>${flor.descripcion}</p>
            </div>
            `;
            cardContainer.appendChild(card);
        });
    }
});
