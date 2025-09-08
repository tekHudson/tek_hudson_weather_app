$(document).ready(function() {
  // Only run on pages with the search form
  if ($('#weather-form').length === 0) {
    return;
  }
  
  const searchInput = $('#search_query');
  const suggestionsDiv = $('#address-suggestions');
  const submitButton = $('button[type="submit"]');
  let debounceTimer;
  let addressSelected = false;
  
  // Update submit button state based on address selection
  function updateSubmitButtonState() {
    if (addressSelected) {
      submitButton.prop('disabled', false).removeClass('btn-secondary').addClass('btn-primary');
    } else {
      submitButton.prop('disabled', true).removeClass('btn-primary').addClass('btn-secondary');
    }
  }
  
  // Check if required elements exist
  if (searchInput.length === 0 || suggestionsDiv.length === 0) {
    return; // Exit if elements not found
  }
  
  // Initialize submit button state (disabled initially)
  updateSubmitButtonState();
  
  // Prevent form submission if no address is selected
  $('#weather-form').on('submit', function(e) {
    if (!addressSelected) {
      e.preventDefault();
      // Show a helpful message
      alert('Please select an address from the suggestions before searching for weather.');
      return false;
    }
  });
  
  function fetchSuggestions(query) {
    $.ajax({
      url: '/addresses/autocomplete',
      method: 'GET',
      data: { q: query },
      dataType: 'json',
      success: function(addresses) {
        showSuggestions(addresses);
      }
    });
  }
  
  function showSuggestions(addresses) {
    if (addresses.length === 0) {
      suggestionsDiv.hide();
      return;
    }
    
    const html = addresses.map(addr => `
      <div class="list-group-item list-group-item-action" data-address="${addr.formatted_address}" data-lat="${addr.lat}" data-lng="${addr.lng}" data-zip_code="${addr.zip_code || ''}">
        <h6 class="mb-1">${addr.formatted_address}</h6>
      </div>
    `).join('');
    
    suggestionsDiv.html(html).show();
    
    // Add click handlers
    suggestionsDiv.find('.list-group-item').on('click', function() {
      const address = $(this).data('address');
      
      // Show the selected address in the input field for user feedback
      searchInput.val(address);

      // Set coordinates for server processing
      $('#hidden_lat').val($(this).data('lat'));
      $('#hidden_lng').val($(this).data('lng'));

      // Extract ZIP code from address and set it
      const zipCode = $(this).data('zip_code');
      $('#hidden_zip_code').val(zipCode);
      
      // Mark address as selected and update button state
      addressSelected = true;
      updateSubmitButtonState();
      
      suggestionsDiv.hide();
    });
  }
  
  // Input event
  searchInput.on('input', function() {
    const searchValue = $(this).val();
    
    // Reset selection state when user types
    addressSelected = false;
    updateSubmitButtonState();
    
    clearTimeout(debounceTimer);
    
    // Show suggestions for addresses (3+ characters)
    if (searchValue.length >= 3) {
      debounceTimer = setTimeout(() => {
        fetchSuggestions(searchValue);
      }, 500); // 500ms delay
    } else {
      suggestionsDiv.hide();
    }
  });
  
  // Hide suggestions when clicking outside
  $(document).on('click', function(e) {
    if (searchInput[0] && suggestionsDiv[0] && 
        !searchInput[0].contains(e.target) && !suggestionsDiv[0].contains(e.target)) {
      suggestionsDiv.hide();
    }
  });
});
