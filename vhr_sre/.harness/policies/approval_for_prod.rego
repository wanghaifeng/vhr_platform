package pipeline

# Rule: An approval step is in place for change/deployments to staging/production environment.

# Deny if pipeline deploys to staging/production but lacks a HarnessApproval step
deny[msg] {
    # Check if pipeline variable 'environment' targets staging or prod
    is_prod_or_staging_env(input.pipeline)

    # Check if there's no approval step in the execution steps
    not has_approval_step(input.pipeline)

    msg = "Pipeline deploys to staging/production but is missing a HarnessApproval step."
}

# Check pipeline variables for environment
is_prod_or_staging_env(pipeline) {
    some i
    variable := pipeline.variables[i]
    variable.name == "environment"
    is_prod_or_staging_string(variable.default)
}

# Check stage environment definitions (if they exist)
is_prod_or_staging_env(pipeline) {
    some i
    stage := pipeline.stages[i].stage
    is_prod_or_staging_stage(stage)
}

is_prod_or_staging_string(env_name) {
    name := lower(env_name)
    contains(name, "prod")
}

is_prod_or_staging_string(env_name) {
    name := lower(env_name)
    contains(name, "staging")
}

# Helper to check if stage implies staging or prod
is_prod_or_staging_stage(stage) {
    name := lower(stage.name)
    contains(name, "prod")
}

is_prod_or_staging_stage(stage) {
    name := lower(stage.name)
    contains(name, "staging")
}

is_prod_or_staging_stage(stage) {
    stage.spec.environment.type == "Production"
}

is_prod_or_staging_stage(stage) {
    stage.spec.environment.type == "PreProduction"
}

# Helper to check if an approval step exists in the pipeline
has_approval_step(pipeline) {
    some i, j
    stage := pipeline.stages[i].stage
    step := stage.spec.execution.steps[j].step
    step.type == "HarnessApproval"
}
