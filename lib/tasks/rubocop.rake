namespace :rubocop do
  desc "Checks the code for linting issues."
  task test: :environment do
    sh "rubocop --fail-level error"
  end

  desc "Actually fixes things that can be automatically fixed. Lower fail level for this."
  task lint: :environment do
    sh "rubocop --fail-level warning -a" # autocorrect safely
  end
end
