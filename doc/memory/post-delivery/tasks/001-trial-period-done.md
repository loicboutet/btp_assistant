# Tâche: Période d'essai gratuite configurable

## Contexte
Modification demandée par Mohamed lors du RDV du 2024-12-XX.
Approuvée par Loïc - Deadline: Lundi

## Description
Permettre aux nouveaux utilisateurs de bénéficier d'une période d'essai gratuite (2 semaines par défaut) avant de devoir payer un abonnement.

## Objectifs
1. L'utilisateur peut utiliser l'outil complet pendant la période d'essai
2. Après expiration → le bot demande le paiement
3. La durée de la période d'essai doit être configurable (admin)

## Modifications requises

### 1. Base de données
- [ ] Ajouter `trial_ends_at:datetime` à la table `users`
- [ ] Ajouter `default_trial_days:integer` à `AppSetting` (défaut: 14)

### 2. Model User
- [ ] Ajouter méthode `in_trial_period?`
- [ ] Ajouter méthode `trial_expired?`
- [ ] Ajouter méthode `trial_days_remaining`
- [ ] Modifier `can_create_documents?` pour inclure la période d'essai
- [ ] Ajouter callback `set_trial_period` après création (si pas de subscription)

### 3. Comportement LLM
- [ ] Modifier la logique de vérification d'abonnement
- [ ] Si `in_trial_period?` → autoriser la création de documents
- [ ] Si `trial_expired?` ET pas d'abonnement → demander le paiement
- [ ] Informer l'utilisateur des jours restants en période d'essai

### 4. Interface Admin
- [ ] Ajouter champ "Durée d'essai par défaut" dans les settings
- [ ] Afficher le statut d'essai dans la liste des utilisateurs
- [ ] Pouvoir étendre/modifier la période d'essai d'un utilisateur

### 5. Interface Client (Profile)
- [ ] Afficher "Période d'essai: X jours restants" si applicable
- [ ] Message d'incitation à s'abonner

## Tests
- [ ] Test `in_trial_period?` retourne true pendant la période
- [ ] Test `in_trial_period?` retourne false après expiration
- [ ] Test création de documents autorisée pendant l'essai
- [ ] Test création de documents refusée après expiration (sans abo)
- [ ] Test création de documents autorisée avec abonnement actif (même après essai)

## Notes
- La période d'essai s'applique à la CRÉATION du compte utilisateur
- Si l'utilisateur paie avant la fin de l'essai, ça n'a pas d'importance
- Un utilisateur avec abonnement actif n'est pas concerné par la logique d'essai
