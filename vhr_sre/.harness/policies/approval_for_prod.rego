package pipeline

# Rule: An approval step is in place for change/deployments to staging/production environment.

# Deny if pipeline deploys to staging/production but lacks a HarnessApproval step
deny[msg] {
    # Check if this pipeline has stages
    some i
    stage := input.pipeline.stages[i].stage

    # Check if stage name or environment relates to staging or production
    is_prod_or_staging(stage)

    # Check if there's no approval step in the execution steps
    not has_approval_step(stage)

    msg = sprintf("Stage '%s' deploys to staging/production but is missing a HarnessApproval step.", [stage.name])
}

# Helper to check if stage implies staging or prod
is_prod_or_staging(stage) {
    name := lower(stage.name)
    contains(name, "prod")
}

is_prod_or_staging(stage) {
    name := lower(stage.name)
    contains(name, "staging")
}

is_prod_or_staging(stage) {
    # If environment type is Production or PreProduction
    stage.spec.environment.type == "Production"
}

is_prod_or_staging(stage) {
    stage.spec.environment.type == "PreProduction"
}

# Helper to check if an approval step exists in the stage
has_approval_step(stage) {
    some j
    step := stage.spec.execution.steps[j].step
    step.type == "HarnessApproval"
}
