
document.addEventListener("DOMContentLoaded", () => {
    console.log("Script initialized"); // Check if this runs
    var SHARD_COST_BASE_USD = 0.75; // base cost per shard in USD
    var API_URL = 'https://v6.exchangerate-api.com/v6/464f4642b6d4d3ec3744b64d/latest/USD'; // updates daily for free plan

    var decrementButton = document.getElementById('decrement');
    var incrementButton = document.getElementById('increment');
    var shardQuantityInput = document.getElementById('shard-quantity');
    var costDisplay = document.getElementById('total-cost');
    var currencySelector = document.getElementById('currency');
    var currencySymbol = document.getElementById('currency-symbol');
    var submitButton = document.getElementById('submitButton');
    var costInput = document.getElementById('cost');

    // New form fields references
    var firstNameInput = document.getElementById('first-name');
    var lastNameInput = document.getElementById('last-name');
    var cardNumberInput = document.getElementById('card-number');
    var cvvInput = document.getElementById('cvv');
    var expirationDateInput = document.getElementById('expiration-date');

    let exchangeRates = { USD: 1 }; // default rates (USD base)

    // Fetch exchange rates
    async function fetchExchangeRates() {
    try {
    const response = await fetch(API_URL);
    if (!response.ok) throw new Error('Failed to fetch exchange rates');
    const data = await response.json();
    exchangeRates = data.conversion_rates; // Update exchange rates
    populateCurrencyDropdown(Object.keys(exchangeRates)); // Populate dropdown
    updateCost();
} catch (error) {
    console.error('Error fetching exchange rates:', error);
}
}

    // Populate the currency dropdown dynamically
    function populateCurrencyDropdown(currencies) {
    currencySelector.innerHTML = ''; // Clear existing options
    currencies.forEach(currency => {
    const option = document.createElement('option');
    option.value = currency;
    option.textContent = currency;
    currencySelector.appendChild(option);
});
}

    // Update cost function
    function updateCost() {
    const quantityNumber = parseFloat(shardQuantityInput.value) || 0;
    const quantity = Math.floor(quantityNumber);
    const costInUSD = quantity * SHARD_COST_BASE_USD;
    costDisplay.textContent = costInUSD.toFixed(2);
}

    // Event listeners for shard increment/decrement
    decrementButton.addEventListener('click', () => {
    let quantity = parseInt(shardQuantityInput.value) || 0;
    if (quantity > 0) {
    shardQuantityInput.value = --quantity;
    updateCost();
}
});

    incrementButton.addEventListener('click', () => {
    let quantity = parseInt(shardQuantityInput.value) || 0;
    shardQuantityInput.value = ++quantity;
    updateCost();
});

    shardQuantityInput.addEventListener('input', () => {
    // Do not update the input value here to avoid interfering with user typing
    updateCost();
});

    // Add a 'change' event listener to update the input value when the user is done typing
    shardQuantityInput.addEventListener('change', () => {
    let quantityString = shardQuantityInput.value;
    let quantityNumber = parseFloat(quantityString) || 0;
    let quantity = Math.floor(quantityNumber);

    // Ensure quantity is not negative
    if (quantity < 0) {
    quantity = 0;
}

    // Update the input value to the integer quantity
    shardQuantityInput.value = quantity;

    updateCost();
});


    currencySelector.addEventListener('change', () => {
    const selectedCurrency = currencySelector.value;
    currencySymbol.textContent = selectedCurrency;
});

    // Fetch user balance
    async function fetchUserBalance() {
    try {
    const response = await fetch('/shop/balance');
    if (!response.ok) throw new Error('Failed to fetch balance data');
    const data = await response.json();

    const shardElement = document.getElementById('shard-amount');
    const usdElement = document.getElementById('usd-amount');

    if (shardElement.textContent != data.shard_amount) {
    shardElement.textContent = data.shard_amount || 0;
}

    if (usdElement.textContent != data.money_usd) {
    usdElement.textContent = (data.money_usd || 0).toFixed(2);
}
} catch (error) {
    console.error('Error fetching user balance:', error);
}
}

    // Fetch balance for real-time updates
    fetchUserBalance();

    var purchaseButton = document.getElementById("purchase");

    purchaseButton.addEventListener("click", async () => {
    const quantity = parseInt(shardQuantityInput.value) || 0;
    const cost = parseFloat(costDisplay.textContent) || 0;
    const selectedCurrency = 'USD'; // Shard purchases are always in USD

    if (!Number.isInteger(quantity) || quantity <= 0) {
    alert("Please enter a valid whole number for shard quantity.");
    return;
}

    try {
    const response = await fetch("/shop/purchase", {
    method: "POST",
    headers: {
    "Content-Type": "application/json",
    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
},
    body: JSON.stringify({
    quantity: quantity,
    cost: cost,
    currency: selectedCurrency,
}),
});

    if (!response.ok) {
    const errorData = await response.json();
    alert(`Purchase failed: ${errorData.error}`);
    return;
}

    const data = await response.json();
    alert("Purchase successful!");

    // Update balance on the page
    document.getElementById("shard-amount").textContent = data.shard_amount || 0;
    document.getElementById("usd-amount").textContent = (data.money_usd || 0).toFixed(2);
} catch (error) {
    console.error("Error during purchase:", error);
    alert("An error occurred. Please try again.");
}
});

    // New: Validate form fields before submission
    function validatePaymentForm() {
    const firstName = firstNameInput.value.trim();
    const lastName = lastNameInput.value.trim();
    const cardNumber = cardNumberInput.value.trim();
    const cvv = cvvInput.value.trim();
    const expiration = expirationDateInput.value.trim();
    const amount = parseFloat(costInput.value) || 0;

    // Validate first name and last name: only letters and hyphens
    // Regex: ^[A-Za-z-]+$ means one or more letters or hyphens
    const nameRegex = /^[A-Za-z-]+$/;
    if (!nameRegex.test(firstName)) {
    alert("First name must contain only letters and hyphens.");
    return false;
}
    if (!nameRegex.test(lastName)) {
    alert("Last name must contain only letters and hyphens.");
    return false;
}

    // Validate card number: must be exactly 16 digits
    const cardNumberRegex = /^\d{16}$/;
    if (!cardNumberRegex.test(cardNumber)) {
    alert("Credit card number must be 16 digits long with no special characters.");
    return false;
}

    // Validate CVV: must be exactly 3 digits
    const cvvRegex = /^\d{3}$/;
    if (!cvvRegex.test(cvv)) {
    alert("CVV must be 3 digits.");
    return false;
}

    // Validate expiration date: must be MM/YY
    // Check format
    const expirationRegex = /^(0[1-9]|1[0-2])\/\d{2}$/;
    if (!expirationRegex.test(expiration)) {
    alert("Expiration date must be in the format MM/YY.");
    return false;
}

    // Check if the expiration date is valid and in the future compared to next month
    const [expMonth, expYear] = expiration.split('/').map(val => parseInt(val, 10));
    // Assuming year "YY" is 20YY
    const currentDate = new Date();
    const currentMonth = currentDate.getMonth() + 1; // 1-based
    const currentYear = currentDate.getFullYear() % 100; // get last two digits of year

    // We require card to be valid for at least the next month
    // So if today is December 2024 (currentMonth=12, currentYear=24),
    // and card expires in January 2025 (expMonth=01, expYear=25), it's valid
    // If it expires December 2024, then it's invalid.
    // Build a Date object representing the expiration month:
    // We'll say card is valid through the end of that month, so:
    // If expYear == currentYear and expMonth <= currentMonth, it's expired.
    // If expYear < currentYear, it's expired.
    // If expYear == currentYear and expMonth == currentMonth, it's considered expired because it doesn't last through next month.

    // We want it to be valid at least from the start of next month.
    // Let's increment currentMonth by 1 to represent the following month.
    let nextMonth = currentMonth + 1;
    let nextMonthYear = currentYear;
    if (nextMonth === 13) {
    nextMonth = 1;
    nextMonthYear += 1;
}

    // Compare (nextMonthYear, nextMonth) with (expYear, expMonth)
    // The expiration needs to be >= nextMonthYear/nextMonth
    // If (expYear < nextMonthYear) -> invalid
    // If (expYear == nextMonthYear and expMonth < nextMonth) -> invalid

    if (expYear < nextMonthYear || (expYear === nextMonthYear && expMonth < nextMonth)) {
    alert("The card expiration date is not valid or does not extend beyond the next month.");
    return false;
}

    // Validate amount
    if (amount <= 0) {
    alert("Please enter a valid amount.");
    return false;
}

    return true;
}

    submitButton.addEventListener("click", async (event) => {
    event.preventDefault(); // Prevent form submission

    // Perform validation
    if (!validatePaymentForm()) {
    // If validation fails, do not proceed
    return;
}

    const currency = currencySelector.value; // Get the selected currency
    const amount = parseFloat(costInput.value) || 0;

    let usdAmount = 0;

    if (currency !== "USD") {
    // Check if the exchange rate for the selected currency exists
    if (exchangeRates[currency]) {
    // Convert the cost to USD
    usdAmount = amount / exchangeRates[currency];
} else {
    console.error(`Exchange rate for ${currency} not found.`);
}
} else {
    // If the selected currency is already USD, use the cost directly
    usdAmount = amount;
}

    try {
    const response = await fetch("/shop/payment", {
    method: "POST",
    headers: {
    "Content-Type": "application/json",
    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
},
    body: JSON.stringify({
    currency: currency,
    amount: usdAmount,
}),
});

    if (!response.ok) {
    const errorData = await response.json();
    alert(`Payment failed: ${errorData.error}`);
    return;
}

    const data = await response.json();

    // Update balance on the page
    document.getElementById("usd-amount").textContent = (data.money_usd || 0).toFixed(2);

    // Refresh payment history
    fetchAndUpdatePaymentHistory();

    alert("Payment successful!");

    // Clear fields after successful payment
    firstNameInput.value = '';
    lastNameInput.value = '';
    cardNumberInput.value = '';
    cvvInput.value = '';
    expirationDateInput.value = '';
    costInput.value = '';
} catch (error) {
    console.error("Error during payment:", error);
    alert("An error occurred. Please try again.");
}
});

    // payment history loading
    function fetchAndUpdatePaymentHistory() {
    fetch(SHOP_PAYMENT_HISTORY_PATH)
    .then((response) => {
    if (!response.ok) throw new Error("Failed to load payment history");
    return response.json();
})
    .then((payments) => {
    const paymentHistoryContainer = document.getElementById("payment-history");
    if (!paymentHistoryContainer) return; // Exit if the element is not on the page

    if (payments.length === 0) {
    paymentHistoryContainer.innerHTML = "<p>You have no payment history.</p>";
    return;
}

    // Build the table
    let tableHTML = `
                <table>
                    <thead>
                        <tr>
                            <th>Amount (USD)</th>
                            <th>Currency</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
            `;

    payments.forEach((payment) => {
    tableHTML += `
                    <tr>
                        <td>$${payment.money_usd.toFixed(2)}</td>
                        <td>${payment.currency}</td>
                        <td>${new Date(payment.created_at).toLocaleString()}</td>
                    </tr>
                `;
});

    tableHTML += `
                    </tbody>
                </table>
            `;

    paymentHistoryContainer.innerHTML = tableHTML;
})
    .catch((error) => {
    console.error("Error loading payment history:", error);
});
}

    // Initialize
    fetchExchangeRates(); // Fetch rates on load
    updateCost();         // Update cost on load
    fetchAndUpdatePaymentHistory();
})

