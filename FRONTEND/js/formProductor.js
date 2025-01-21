document.addEventListener('DOMContentLoaded', () => {
    const selectElement = document.getElementById('productorSelect');
    const florproductorSelect = document.getElementById('florproductorSelect');
    const messageContainer = document.getElementById('messageContainer');

    // Realiza una solicitud a la API para obtener los productores
    fetch('/productores')
        .then(response => {
            if (!response.ok) {
                throw new Error('Error al obtener los productores');
            }
            return response.json();
        })
        .then(data => {
            console.log('Datos recibidos:', data);
            data.forEach(productor => {
                const optionElement = document.createElement('option');
                optionElement.value = productor.id_productor;
                optionElement.textContent = productor.nombre_productor;
                selectElement.appendChild(optionElement);
            });
        })
        .catch(error => console.error('Error al obtener los productores:', error));

    // Hacer fetch inicial para obtener todas las flores
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
    formProductorCatalogo.addEventListener('submit', (event) => {
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
  const productorid = document.getElementById('productorSelect').value;
  const florCorte = document.getElementById('florproductorSelect').value;
  const vbn = document.getElementById('vbn').value;
  const nombre = document.getElementById('name').value;
  const descripcion = document.getElementById('descripcion').value;
 // const logo = document.getElementById('logo').value;
 const formData = new FormData();
 formData.append('productorid', productorid);
 formData.append('florCorte', florCorte);
 formData.append('vbn', vbn);
 formData.append('nombre', nombre);
 formData.append('descripcion', descripcion);

 const logoInput = document.getElementById('logo');
  if (logoInput.files.length > 0) {
    formData.append('logo', logoInput.files[0]);
  }
  // Enviar los datos al servidor 
  fetch('/post-catalogo-productor', {
    method: 'POST',
    body: formData
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