const airportImages = {
    lsia: "images/lsia.jpg",
    sandy: "images/sandy_shores.jpg",
    paleto: "images/paleto_bay.jpg",
  };
  
  const airports = {
    lsia: {
      label: "Los Santos International",
      flights: [
        { label: "Sandy Shores Airfield", to: "sandy", price: 250 },
        { label: "Paleto Bay Airstrip", to: "paleto", price: 500 },
      ],
    },
    sandy: {
      label: "Sandy Shores Airfield",
      flights: [
        { label: "Los Santos International", to: "lsia", price: 250 },
        { label: "Paleto Bay Airstrip", to: "paleto", price: 300 },
      ],
    },
    paleto: {
      label: "Paleto Bay Airstrip",
      flights: [
        { label: "Los Santos International", to: "lsia", price: 500 },
        { label: "Sandy Shores Airfield", to: "sandy", price: 300 },
      ],
    },
  };
  
  let selectedFlight = null;
  let currentAirport = null;
  
  window.addEventListener("message", (event) => {
    const data = event.data;
  
    if (data.action === "open") {
      currentAirport = data.airport;
      selectedFlight = null;
      openUI(currentAirport);
    }
  
    if (data.action === "close") {
      closeUI();
    }
  });
  
  function openUI(airportKey) {
    const flightList = document.getElementById("flight-list");
    if (!flightList) return;
  
    flightList.innerHTML = "";
  
    const airport = airports[airportKey];
    if (!airport) return;
  
    // Vlucht opties toevoegen
    airport.flights.forEach((flight) => {
      const el = document.createElement("div");
      el.className = "flight-item";
      el.dataset.to = flight.to;
      el.innerHTML = `
        <div class="label">${flight.label}</div>
        <div class="price">
          <span class="currency-icon">€</span>${flight.price}
        </div>
      `;
      el.addEventListener("click", () => selectFlight(flight.to, el));
      flightList.appendChild(el);
    });
  
    // Titel en subtitle updaten
    const titleEl = document.getElementById("airport-title");
    const subtitleEl = document.getElementById("airport-subtitle");
    if (titleEl) titleEl.innerText = airport.label;
    if (subtitleEl) subtitleEl.innerText = "Kies jouw bestemming";
  
    // Afbeelding met fade-in
    const imgEl = document.getElementById("airport-image");
    if (imgEl && airportImages[airportKey]) {
      imgEl.style.opacity = "0";
      imgEl.src = airportImages[airportKey];
      imgEl.style.display = "block";
      imgEl.onload = () => {
        imgEl.style.transition = "opacity 0.5s ease";
        imgEl.style.opacity = "1";
      };
    } else if (imgEl) {
      imgEl.style.display = "none";
    }
  
    // Confirm knop resetten
    const confirmBtn = document.getElementById("confirm-btn");
    if (confirmBtn) confirmBtn.disabled = true;
  
    // UI tonen met fade effect
    const ui = document.getElementById("airport-ui");
    if (ui) {
      ui.style.opacity = "0";
      ui.style.display = "flex";
      setTimeout(() => {
        ui.style.transition = "opacity 0.3s ease";
        ui.style.opacity = "1";
      }, 50);
    }
  
    document.body.classList.add("menu-open");
  }
  
  function closeUI() {
    const ui = document.getElementById("airport-ui");
    if (ui) {
      ui.style.transition = "opacity 0.3s ease";
      ui.style.opacity = "0";
      setTimeout(() => {
        ui.style.display = "none";
      }, 300);
    }
  
    document.body.classList.remove("menu-open");
  
    selectedFlight = null;
    currentAirport = null;
  
    document.querySelectorAll(".flight-item").forEach((el) => {
      el.classList.remove("selected");
    });
  
    fetch(`https://${GetParentResourceName()}/close`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({}),
    });
  }
  
  function selectFlight(to, element) {
    if (selectedFlight === to) return; // zelfde item klikken negeren
  
    selectedFlight = to;
  
    document.querySelectorAll(".flight-item").forEach((el) => {
      el.classList.remove("selected");
    });
    element.classList.add("selected");
  
    const confirmBtn = document.getElementById("confirm-btn");
    if (confirmBtn) confirmBtn.disabled = false;
  }
  
  async function confirmFlight() {
    if (!selectedFlight || !currentAirport) return;
  
    const confirmBtn = document.getElementById("confirm-btn");
    if (confirmBtn) {
      confirmBtn.disabled = true;
      confirmBtn.innerText = "Bezig...";
    }
  
    try {
      await fetch(`https://${GetParentResourceName()}/selectFlight`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ to: selectedFlight }),
      });
    } catch (e) {
      console.error("Error bij selectFlight:", e);
    }
  
    // Sluit UI na succesvolle call
    closeUI();
  
    if (confirmBtn) {
      confirmBtn.innerText = "Bevestig vlucht";
      confirmBtn.disabled = false;
    }
  }
  