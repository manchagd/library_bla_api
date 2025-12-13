# frozen_string_literal: true

require 'pagy/extras/metadata'
require 'pagy/extras/overflow'

# Pagy initializer file
# See https://ddnexus.github.io/pagy/docs/api/pagy#root-variable
Pagy::DEFAULT[:items] = 20
Pagy::DEFAULT[:overflow] = :last_page
