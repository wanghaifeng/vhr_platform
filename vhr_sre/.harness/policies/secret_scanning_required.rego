package pipeline

# Rule: A secret scanning step is in place to ensure no credentials are hard coded in code base.

# Deny if pipeline lacks a secret scanning step
deny[msg] {
    not has_secret_scan_step(input.pipeline)
    msg = "Pipeline is missing a mandatory Secret Scanning step to ensure no credentials are hard coded in the codebase."
}

has_secret_scan_step(pipeline) {
    some i, j
    stage := pipeline.stages[i].stage
    step := stage.spec.execution.steps[j].step
    
    # Check if the step is a Run step executing a secret scanning tool like git-secrets, gitleaks, or trivy
    step.type == "Run"
    is_secret_scan_command(step.spec.command)
}

has_secret_scan_step(pipeline) {
    some i, j
    stage := pipeline.stages[i].stage
    step := stage.spec.execution.steps[j].step
    
    # Or if Harness has a built-in secret scanning step (e.g. STOSecurity or similar plugin)
    step.type == "Plugin"
    contains(lower(step.spec.image), "secret-scan")
}

is_secret_scan_command(command) {
    contains(lower(command), "gitleaks")
}

is_secret_scan_command(command) {
    contains(lower(command), "trivy fs")
}

is_secret_scan_command(command) {
    contains(lower(command), "git-secrets")
}
