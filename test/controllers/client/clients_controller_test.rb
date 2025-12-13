# frozen_string_literal: true

# Backwards-compat shim:
# Les contrôleurs artisan ont été déplacés sous le namespace Portal pour éviter
# la collision avec le modèle ActiveRecord `Client`.
# On garde ces fichiers pour que `bin/rails test test/controllers/client/*` continue de fonctionner.

require_relative "../portal/clients_controller_test"
