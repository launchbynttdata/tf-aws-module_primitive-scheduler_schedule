package testimpl

import "github.com/launchbynttdata/lcaf-component-terratest/types"

type ThisTFModuleConfig struct {
	types.GenericTFModuleConfig
	// Scheduler schedule module has no additional test config.
}
