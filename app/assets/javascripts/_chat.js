var chatPoll;
updateChat()

document.getElementById('submit_button').addEventListener('click', () => {
    let input = document.getElementById('message_input');
    fetch(`/chat?message=${input.value}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken
        },
    });


    // clear the input field.
    input.value = "";
    updateChat();
});

async function updateChat() {
    clearTimeout(chatPoll) //If this gets manually called, do not recall it while executing.
    let response = (await fetch(`/chat`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken
        },
    }));
    const chatLog = await (response.json())

    const chatBox = document.getElementById('chat-messages')

    if (chatBox)
        chatBox.innerHTML = '' // Remove the old chat messages

    for (const message of chatLog.chatLog) { // Create the new messages.
        let newEntry = document.createElement('div')
        newEntry.innerHTML = '<strong>'+message.user+':</strong> '+message.message
        if (chatBox)
            chatBox.appendChild(newEntry)
    }

    chatPoll = setTimeout(() => {updateChat()}, 3000) // Call myself again 3 seconds after the last time I have been called.
}