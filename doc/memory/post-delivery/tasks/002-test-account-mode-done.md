# Tâche: Compte test/admin sans abonnement

## Contexte
Modification demandée par Mohamed lors du RDV du 2024-12-XX.
Approuvée par Loïc - Deadline: Lundi

## Description
Permettre de créer des comptes utilisateurs avec un accès permanent sans nécessiter d'abonnement. Utile pour :
- Mohamed (le client) pour tester l'application
- Comptes de démonstration
- Comptes spéciaux

## Objectifs
1. Un admin peut marquer un compte comme "accès gratuit permanent"
2. Ces comptes peuvent créer des documents sans limite
3. Ces comptes n'apparaissent pas dans les métriques d'abonnement

## Modifications requises

### 1. Base de données
- [ ] Ajouter `bypass_subscription:boolean` à la table `users` (défaut: false)

### 2. Model User
- [ ] Modifier `can_create_documents?` pour vérifier `bypass_subscription`
- [ ] Ajouter scope `billable` (exclut les bypass)
- [ ] Ajouter scope `with_bypass` (uniquement les bypass)

### 3. Comportement LLM
- [ ] Si `bypass_subscription == true` → ne jamais demander de paiement
- [ ] Autoriser toutes les fonctionnalités

### 4. Interface Admin (Users)
- [ ] Ajouter toggle "Accès gratuit permanent" sur la page user
- [ ] Ajouter badge visuel dans la liste des utilisateurs
- [ ] Filtrer les utilisateurs bypass dans les statistiques d'abonnement

### 5. Interface Admin (Dashboard)
- [ ] Ne pas compter les bypass dans "Utilisateurs payants"
- [ ] Ajouter métrique "Comptes test" si > 0

## Tests
- [ ] Test `can_create_documents?` retourne true si bypass
- [ ] Test scope `billable` exclut les bypass
- [ ] Test création de documents autorisée même sans abo/trial

## Sécurité
- [ ] Seul un admin peut activer/désactiver le bypass
- [ ] Logger l'activation/désactivation dans SystemLog

## Notes
- Ce flag est indépendant de la période d'essai
- Un compte bypass peut aussi avoir un abonnement (cas rare mais possible)
- L'ordre de vérification devrait être: bypass → subscription active → trial period → refus
