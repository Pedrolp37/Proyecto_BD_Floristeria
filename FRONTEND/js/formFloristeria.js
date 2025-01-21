document.addEventListener('DOMContentLoaded', () => {
    const florproductorSelect = document.getElementById('florSelect');
    const floristeriaSelect = document.getElementById('floristeriaSelect');
    const coloresSelect = document.getElementById('colorSelect');
 
    fetch('/floristerias')
        .then(response => {
            if (!response.ok) {
                throw new Error('Error al obtener las floristerias');
            }
            return response.json();
        })
        .then(data => {
    
            data.forEach(floris => {
                const optionElement = document.createElement('option');
                optionElement.value = floris.id_floristeria;
                optionElement.textContent = floris.nombre;
                floristeriaSelect.appendChild(optionElement);
            });
        })
        .catch(error => console.error('Error al obtener las floristerias:', error));

        fetch('/colores')
        .then(response => {
            if (!response.ok) {
                throw new Error('Error al obtener los colores');
            }
            return response.json();
        })
        .then(data => {
    
            data.forEach(color => {
                const optionElement = document.createElement('option');
                optionElement.value = color.codigo_color;
                optionElement.textContent = color.color;
                coloresSelect.appendChild(optionElement);
            });
        })
        .catch(error => console.error('Error al obtener los colores:', error));

    fetch('/florCorte')
        .then(response => {
            if (!response.ok) {
                throw new Error('Error al obtener las flores');
            }
            return response.json();
        })
        .then(data => {
            floresData = data;
            data.forEach(flor => {
                const optionElement = document.createElement('option');
                optionElement.value = flor.id_corte;
                optionElement.textContent = flor.nombre_comun;
                florproductorSelect.appendChild(optionElement);
            });
        })
        .catch(error => console.error('Error al obtener las flores del productor:', error));

    // Añadir evento change para cuando se seleccione una flor
    florproductorSelect.addEventListener('change', (event) => {
      const florId = event.target.value;
      displayFlowerInfo(florId, floresData);
    });

     // Capturar el evento de envío del formulario
     formFloristeriaCatalogo.addEventListener('submit', (event) => {
      event.preventDefault();
      // Prevenir el envío del formulario por defecto
      enviarFormulario();
    });

});

function displayFlowerInfo(florId, floresData) {
    // Encontrar la flor en los datos almacenados usando el id_corte
    const flor = floresData.find(f => f.id_corte === florId);
     if (flor) {
      document.getElementById('genero').value = flor.genero_especie;
      document.getElementById('etimologia').value = flor.etimologia;
      document.getElementById('colores').value = flor.colores;
      document.getElementById('temperatura').value = flor.temperatura;
    }else{
      console.error('Flor no encontrada');
    } 
  }

  function enviarFormulario(){
    const floristeriaID = document.getElementById('floristeriaSelect').value;
    const florCorte = document.getElementById('florSelect').value;
    const nombre = document.getElementById('name_flor').value;
    const descripcion = document.getElementById('descripcion').value;
    const color_id = document.getElementById('colorSelect').value;

    // Recopilar datos del formulario en un objeto
    const formData = {
      floristeriaID,
      florCorte,
      color_id,
      nombre,
      descripcion
    }; 
    // Enviar los datos al servidor 
    fetch('/post-catalogo-floristeria', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      }, 
      body: JSON.stringify(formData)
    })
    .then(response => response.json())
    .then(data => {
      console.log('Formulario enviado:', data);
      mostrarMensaje('Flor añadida al catálogo exitosamente', 'success');
      // Manejar la respuesta del servidor aquí, como mostrar un mensaje de éxito 
    }) 
    .catch(error => console.error('Error al enviar el formulario:', error));
    mostrarMensaje('Error al añadir la flor al catálogo', 'error');
  }

  function mostrarMensaje(mensaje, tipo) { 
    const messageContainer = document.getElementById('messageContainer'); 
    messageContainer.textContent = mensaje; 
    messageContainer.className = ''; // Resetear clases 
    messageContainer.classList.add(tipo); // Añadir clase según el tipo ('success' o 'error') 
    messageContainer.style.display = 'block'; // Mostrar el contenedor 
  }