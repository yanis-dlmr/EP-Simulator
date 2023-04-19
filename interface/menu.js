function toggleDropdown(btn) {
    btn.classList.toggle("open");
}

const loadingContainer = document.getElementById("loadingId");
loadingContainer.classList.add("loading-container");
loadingContainer.id = "loading-container";
loadingContainer.style.display = "none";

const spinner = document.createElement("div");
spinner.classList.add("spinner-border", "text-primary");
spinner.role = "status";

const spinnerText = document.createElement("span");
spinnerText.classList.add("visually-hidden");
spinnerText.textContent = "Loading...";

spinner.appendChild(spinnerText);
loadingContainer.appendChild(spinner);


var fileName = location.pathname.split("/").pop();

fetch('structure.json')
    .then(response => response.json())
    .then(data => {
        var menu = document.getElementById('menuId');
        menu.classList.add('vertical-menu');

        data.pages.forEach(function(page, pageIndex) {

            if (page.subPages) {
                // création du bouton affichant le dropdown-container
                var dropdownBtn = document.createElement('a');
                //dropdownBtn.classList.add('btn');
                dropdownBtn.classList.add('dropdown-btn');
                dropdownBtn.href = '#';
                dropdownBtn.textContent = page.name;
                dropdownBtn.addEventListener('click', function(event) {
                    event.preventDefault();
                    toggleDropdown(this);
                });
                // création de la flèche contenu dans dropdownBtn
                var arrow = document.createElement('span')
                arrow.classList.add('arrow')
                dropdownBtn.appendChild(arrow)
                menu.appendChild(dropdownBtn);
                // création du container contenant les subLink
                var dropdownContainer = document.createElement('div');
                dropdownContainer.classList.add('dropdown-container');
                page.subPages.forEach(function(subPage, subPageIndex){
                    var subLink = document.createElement('a');
                    subLink.classList.add('menu-btn');
                    subLink.classList.add('sous-btn');
                    subLink.href = subPage.link;
                    subLink.textContent = subPage.name;
                    if (subPage.link.toString() == fileName.toString()) {
                        subLink.classList.add('active');
                        dropdownBtn.classList.toggle("open");
                        dropdownContainer.style.display = "block";
                    }
                    dropdownContainer.appendChild(subLink);
                });
                menu.appendChild(dropdownContainer);
            } else {
                // création d'un link simple
                var link = document.createElement('a');
                link.classList.add('menu-btn');
                link.href = page.link;
                link.textContent = page.name;
                if (page.link.toString() == fileName.toString()) {
                    link.classList.add('active');
                }
                menu.appendChild(link);
            };

            // mise en évidence des boutons sélectionnés
            const btns = document.querySelectorAll(".vertical-menu .menu-btn");
            btns.forEach((btn) => {
                btn.addEventListener("click", () => {
                    btns.forEach((btn) => {
                        btn.classList.remove("active");
                    });
                    btn.classList.add("active");
                });
            });
            const subBtns = document.querySelectorAll(".dropdown-container .sous-btn");
            subBtns.forEach((subBtn) => {
                subBtn.addEventListener("click", () => {
                    subBtns.forEach((subBtn) => {
                        subBtn.classList.remove("active");
                    });
                    subBtn.classList.add("active");
                });
            });

        });
        const dropdown = document.getElementsByClassName("dropdown-btn");
        for (let i = 0; i < dropdown.length; i++) {
        dropdown[i].addEventListener("click", function() {
            this.classList.toggle("active");
            var dropdownContent = this.nextElementSibling;
            if (dropdownContent.style.display === "block") {
            dropdownContent.style.display = "none";
            } else {
            dropdownContent.style.display = "block";
            }
        });
        }

    });
