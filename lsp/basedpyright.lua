return {
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = "basic",  -- or "standard"/"strict" for stricter checks
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                autoImportCompletions = true,

            --     -- Silence everything that's not core type checking
            --     diagnosticSeverityOverrides = {
            --         reportUnusedVariable = "none",
            --         reportUnusedImport = "none",
            --         reportUnusedClass = "none",
            --         reportUnusedFunction = "none",
            --         reportDuplicateImport = "none",
            --         reportUnusedCoroutine = "none",
            --         reportUnusedExpression = "none",
            --         reportPrivateUsage = "none",
            --         reportConstantRedefinition = "none",
            --         reportInconsistentConstructor = "none",
            --         reportUnnecessaryCast = "none",
            --         reportUnnecessaryComparison = "none",
            --         reportUnnecessaryContains = "none",
            --         reportUnnecessaryIsInstance = "none",
            --         reportMissingTypeStubs = "none",
            --         reportUnknownVariableType = "none",
            --         reportUnknownParameterType = "none",
            --         reportUnknownMemberType = "none",
            --         reportMissingParameterType = "none",
            --         reportInvalidTypeVarUse = "none",
            --         reportUnsupportedDunderAll = "none",
            --         reportUntypedFunctionDecorator = "none",
            --         reportImplicitStringConcatenation = "none",
            --         reportOverlappingOverload = "none",
            --         reportImportCycles = "none",
            --     },
            },
        },
    },
}
