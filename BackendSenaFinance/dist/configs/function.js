"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.calculeTempTravail = exports.convertToMinutes = exports.ajouterPeriode = void 0;
exports.cryptage = cryptage;
exports.decryptage = decryptage;
exports.recupererJourSemaine = recupererJourSemaine;
exports.getJour = getJour;
const CryptoJS = require("crypto-js");
// const cleSecrete = process.env.MOT_CLE; // "?C-8H[r8X6R5F{5(M4a2}P/]h_2p%iTRu7vkq5x4EX9YjzC2Tc6=z;cw~8.64KkZ*@aM6$";
const cleSecrete = process.env.CLE_SECRETE;
console.log("LE MOT CLES SECRET EST ==> ", cleSecrete);
function cryptage(lemot = "") {
    let motCrypter = "";
    do {
        // Chiffrer la chaîne de caractères
        motCrypter = CryptoJS.AES.encrypt(lemot, cleSecrete).toString();
    } while (motCrypter.includes('/')); // Vérifier s'il contient "/"
    return motCrypter;
}
function decryptage(lemot = "") {
    console.log("cleSecrete ==>", cleSecrete);
    const bytes = CryptoJS.AES.decrypt(lemot, cleSecrete);
    return bytes.toString(CryptoJS.enc.Utf8);
}
const ajouterPeriode = (dateStr, x, frequence) => {
    // Convertir la date en objet Date
    let date = new Date(dateStr);
    // Vérifier la fréquence et ajouter la quantité appropriée
    switch (frequence.toLowerCase()) {
        case "jour":
        case "jours":
            date.setDate(date.getDate() + x);
            break;
        case "mois":
            date.setMonth(date.getMonth() + x);
            break;
        case "année":
        case "années":
        case "an":
        case "ans":
            date.setFullYear(date.getFullYear() + x);
            break;
        case "semaine":
        case "semaines":
            date.setDate(date.getDate() + (x * 7));
            break;
        default:
            console.error("Fréquence non reconnue : ", frequence);
            return null;
    }
    // Retourner la nouvelle date formatée en ISO (aaaa-mm-jj)
    return date.toISOString().split('T')[0];
};
exports.ajouterPeriode = ajouterPeriode;
function recupererJourSemaine(dateS) {
    const date = new Date(dateS);
    const joursSemaine = ["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"];
    return joursSemaine[date.getDay()];
}
function getJour(dateStr) {
    // Tableau des noms des jours en français
    const jours = ["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"];
    // Convertir la dateStr en objet Date
    const date = new Date(dateStr);
    // Vérifier si la date est valide
    if (isNaN(date.getTime())) {
        throw new Error("Date invalide");
    }
    // Obtenir le jour de la semaine et retourner le nom du jour
    return jours[date.getDay()];
}
// Fonction utilitaire pour convertir une heure au format HH:mm en minutes
const convertToMinutes = (time) => {
    const [hours, minutes] = time.split(":").map(Number);
    return hours * 60 + minutes;
};
exports.convertToMinutes = convertToMinutes;
// Fonction pour calculer le temps de travail total
const calculeTempTravail = (horaires) => {
    let totalMinutes = 0;
    console.log("ICIC ");
    for (let jour of horaires) { // horaires.forEach((jour) =>
        console.log("ICIC ");
        if (jour.estActif) {
            const heureOuvertureMinutes = jour.heureArrive ? (0, exports.convertToMinutes)(jour.heureArrivee) : 0;
            const heureFermetureMinutes = jour.heureDepart ? (0, exports.convertToMinutes)(jour.heureDepart) : 0;
            const heureDebutPauseMinutes = jour.heureDebutPause ? (0, exports.convertToMinutes)(jour.heureDebutPause) : 0;
            const heureFinPauseMinutes = jour.heureFinPause ? (0, exports.convertToMinutes)(jour.heureFinPause) : 0;
            console.log("parseInt((heureFermetureMinutes - heureOuvertureMinutes).toString()) - parseInt((heureFinPauseMinutes - heureDebutPauseMinutes).toString())", parseInt((heureFermetureMinutes - heureOuvertureMinutes).toString()) - parseInt((heureFinPauseMinutes - heureDebutPauseMinutes).toString()));
            // Calculer le temps de travail (heure de fermeture - heure d'ouverture) - pause
            const tempsTravail = parseInt((heureFermetureMinutes - heureOuvertureMinutes).toString()) - parseInt((heureFinPauseMinutes - heureDebutPauseMinutes).toString());
            console.log("tempsTravail == > ", tempsTravail);
            totalMinutes += tempsTravail;
        }
    }
    ;
    // Convertir le total des minutes en heures et minutes
    const heures = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    return heures + ":" + minutes;
};
exports.calculeTempTravail = calculeTempTravail;
