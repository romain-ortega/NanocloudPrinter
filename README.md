#Nanocloud Printer

##Dependances

    - PostScript: Interpreteur PostScript, Conversion en PDF. PDF to jpg etc.
    - Redmon: Permet de creer des ports d'imprimantes rediriges.
    - zlib, libpng


##Installation

L'installation se lance via l'installeur present dans le dossier Install/

    - Ajout du .exe, .dll, .. dans Program Files x86
    - Inscription du path du binaire dans le registre Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Monitors\CCDPF_Redmon\Ports\CCPDFPort
    - D'autres choses inutiles pour nous (binaire de desinstallation etc...)

Le binaire d'installation est genere via le script CCPDFConverterInstall.nsi
L'installation silencieuse se fait avec l'option /S

##Execution

Lorsqu'un utilisateur choisi de lancer une impression le binaire genere dans
CCPDFConverter/ est appele, c'est dans ce dossier qu'il y a les sources
a modifier pour la communication avec Photon.

Redmon envoi les donnees du fichier pdf sur stdin (via CCPDF_redmon.dll)
Le buffer envoye commence par `%%File`.

##TODO

    - Supprimer le binaire d'installation et inscrire le driver dans le registre
        windows nous meme.
    - Communiquer le path du fichier a Photon ou lui envoyer le fileInput
        directement (sans ecrire dans un fichier).

