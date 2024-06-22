window.addEventListener('message', function(event) {
    if (event.data.type === "open") {
        document.getElementById('menu').style.display = 'flex';
        let questList = document.getElementById('quest-list');
        questList.innerHTML = '';
        event.data.quests.forEach(quest => {
            let questItem = document.createElement('li');
            questItem.innerText = `${quest.name} - ${quest.description}`;
            questItem.onclick = () => startQuest(quest);
            questList.appendChild(questItem);
        });
    } else if (event.data.type === "close") {
        document.getElementById('menu').style.display = 'none';
    }
});

function startQuest(quest) {
    fetch(`https://${GetParentResourceName()}/startQuest`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ quest: quest })
    }).then(resp => resp.json()).then(resp => {
        if (resp === 'ok') {
            closeMenu();
        }
    });
}

function closeMenu() {
    document.getElementById('menu').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        }
    }).then(resp => resp.json());
}
