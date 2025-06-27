# LogisticsManager Documentation

## Overview

The **LogisticsManager** is a centralized system that handles resource distribution between buildings in your game. It automatically matches buildings that need resources with buildings that have available resources, then dispatches drones to transfer materials between them.

## Key Features

- **Automatic Resource Matching**: Automatically pairs resource requests with available resources
- **Drone Management**: Handles drone dispatching for resource transfers
- **Building Registration**: Tracks all buildings in the logistics network
- **Queue Processing**: Continuously processes resource requests and offers

## How It Works

### 1. Building Registration
Buildings must register themselves with the LogisticsManager to participate in the logistics network:

```gdscript
func _ready():
    if LogisticsManager.instance:
        LogisticsManager.instance.register_building(self)
    else:
        push_error("LogisticsManager not found!")
```

### 2. Resource Communication
Buildings communicate their resource needs and availability through signals:

#### Requesting Resources
When a building needs resources, it emits a `resource_needed` signal:

```gdscript
# Example: Request 5 units of iron ore
emit_signal("resource_needed", self, iron_ore_material, 5)
```

#### Offering Resources
When a building has resources available, it emits a `resource_available` signal:

```gdscript
# Example: Offer 10 units of steel
emit_signal("resource_available", self, steel_material, 10)
```

### 3. Automatic Processing
The LogisticsManager continuously:
- Monitors resource requests and offers
- Matches compatible requests with offers
- Dispatches available drones to transfer resources
- Updates quantities as transfers complete

## Implementation Example

Here's how the BaseFactory successfully integrates with LogisticsManager:

### Setup in _ready()
```gdscript
func _ready():
    # Register with logistics system
    if LogisticsManager.instance:
        LogisticsManager.instance.register_building(self)
    else:
        push_error("LogisticsManager not found!")
```

### Requesting Resources During Production
```gdscript
func _produce():
    var missing_resources := false
    
    # Check if we have enough resources
    for resource in data.consumed_resources.keys():
        var required_amount := data.consumed_resources[resource]
        if not inventory.has_enough(resource, required_amount):
            missing_resources = true
            var amount_needed := inventory.max_capacity - inventory.count(resource)
            # Request resources from logistics system
            emit_signal("resource_needed", self, resource, amount_needed)
    
    # Only produce if we have all required resources
    if missing_resources:
        return
    
    # Continue with production...
```

### Offering Resources After Production
```gdscript
func _produce():
    # ... production logic ...
    
    # Add produced resources to inventory
    for resource in data.produced_resource.keys():
        inventory.add_resource(resource, data.produced_resource[resource])
        # Notify logistics system about available resources
        emit_signal("resource_available", self, resource, inventory.count(resource))
```

## Required Building Setup

For a building to work with LogisticsManager, it needs:

### 1. Required Components
- **InventoryComponent**: To store resources
- **Resource Data**: MaterialData objects for different resource types

### 2. Required Signals
```gdscript
signal resource_available(building, material, amount)
signal resource_needed(building, material, amount)
```

### 3. Registration Call
```gdscript
func _ready():
    if LogisticsManager.instance:
        LogisticsManager.instance.register_building(self)
```

### 4. Signal Emissions
- Emit `resource_needed` when requiring resources
- Emit `resource_available` when resources are produced or available

## Monitoring System Status

You can check the logistics system status:

```gdscript
var status = LogisticsManager.instance.get_queue_status()
print("Requests: ", status.requests)
print("Offers: ", status.offers)
print("Available Drones: ", status.available_drones)
print("Busy Drones: ", status.busy_drones)
```

## Best Practices

### 1. Resource Amount Calculation
When requesting resources, consider requesting up to your maximum capacity:
```gdscript
var amount_needed := inventory.max_capacity - inventory.count(resource)
```

### 2. Signal Timing
- Emit `resource_needed` during production checks
- Emit `resource_available` after successful production
- Update offers when inventory changes

### 3. Error Handling
Always check if LogisticsManager exists before using it:
```gdscript
if LogisticsManager.instance:
    LogisticsManager.instance.register_building(self)
else:
    push_error("LogisticsManager not found!")
```

### 4. Performance Considerations
- The system automatically handles duplicate requests (overwrites existing ones)
- No need to manually track or cancel requests
- The system processes continuously, so avoid excessive signal emissions

## Troubleshooting

### Common Issues

1. **Building not receiving resources**: Ensure the building is registered and emitting `resource_needed` signals

2. **Resources not being offered**: Check that `resource_available` signals are being emitted after production

3. **No drone transfers**: Verify that:
   - DroneManager is properly configured
   - Drones are available
   - Resource types match exactly between requests and offers

4. **Duplicate requests**: The system automatically handles this by overwriting existing requests with the same building/material combination

## Scene Structure

Ensure your scene has this structure:
```
Main
├── LogisticsManager
│   ├── DroneManager
│   └── BuildingTracker
├── Factory1 (extends BaseFactory)
├── Factory2 (extends BaseFactory)
└── ... other buildings
```

The LogisticsManager should be available as a singleton or accessible instance before buildings are initialized.