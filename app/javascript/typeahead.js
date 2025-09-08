$(document).ready(function() {
  // Only run on pages with the search form
  if ($('#weather-form').length === 0) {
    return;
  }
  
  const $searchInput = $('#search_query');
  const $suggestionsDiv = $('#address-suggestions');
  let debounceTimer;
  
  // Check if required elements exist
  if ($searchInput.length === 0 || $suggestionsDiv.length === 0) {
    return; // Exit if elements not found
  }
  
  function fetchSuggestions(query) {
    $.ajax({
      url: '/addresses/autocomplete',
      method: 'GET',
      data: { q: query },
      dataType: 'json',
      success: function(addresses) {
        showSuggestions(addresses);
      },
      error: function(xhr, status, error) {
        // Silently handle errors
      }
    });
  }
  
  function showSuggestions(addresses) {
    if (addresses.length === 0) {
      $suggestionsDiv.hide();
      return;
    }
    
    const html = addresses.map(addr => `
      <div class="list-group-item list-group-item-action" data-address="${addr.formatted_address}" data-lat="${addr.lat}" data-lon="${addr.lon}">
        <h6 class="mb-1">${addr.formatted_address}</h6>
      </div>
    `).join('');
    
    $suggestionsDiv.html(html).show();
    
    // Add click handlers
    $suggestionsDiv.find('.list-group-item').on('click', function() {
      const $this = $(this);
      $searchInput.val($this.data('address'));
      $('#hidden_lat').val($this.data('lat'));
      $('#hidden_lng').val($this.data('lon'));
      $suggestionsDiv.hide();
    });
  }
  
  // Input event
  $searchInput.on('input', function() {
    const value = $(this).val();
    
    clearTimeout(debounceTimer);
    
    // Show suggestions for addresses (3+ characters) but not for zip codes (5 digits)
    if (value.length >= 3 && !value.match(/^\d{5}$/)) {
      debounceTimer = setTimeout(() => {
        fetchSuggestions(value);
      }, 500); // 500ms delay
    } else {
      $suggestionsDiv.hide();
    }
  });
  
  
  // Hide suggestions when clicking outside
  $(document).on('click', function(e) {
    if ($searchInput[0] && $suggestionsDiv[0] && 
        !$searchInput[0].contains(e.target) && !$suggestionsDiv[0].contains(e.target)) {
      $suggestionsDiv.hide();
    }
  });
  
});
