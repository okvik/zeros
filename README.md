# Zeros (WIP)

A very much work in progress of an alternative ecosystem for ROS 2
development including a client library, message generation, package
build support, and so on; for developing simple and efficient robotics
applications while minimizing contact surface with awful languages,
dreadful compile times, (micro) dependency hell, and other common
afflictions.

## Client library

A fully-featured (eventually) client library based on `rcl` and `rclc`.

### TODO

* Context
* QoS
* Subscriptions
* Publishers
* Services
* Actions
* Parameters
* Timers
* Executors
* RMW specifics

## Message generation

### TODO

* Decide on external code generator executable vs. comptime.
  I'm not sure that fully comptime is even possible, given some
  Zig limitations. It would be especially hard or impossible to
  provide a nice API for the message types, so codegen is probably
  the way to go.
* A Zig message generator integrated into the ROS 2 build pipeline is
  not something that matches with the goals of this project. As much
  as practically possible we'd like to operate independent of the
  standard ROS 2 build environment and only interface with its
  artifacts as a dumb participant based on system interfaces and
  established conventions.

## Build support

### TODO

* Resource index
* Discovering transitive dependencies

## Other

## Longer-term ideas

* From source build of the entire ROS 2 core using the Zig build
  system; for cross-compilation, static linking, better control over
  the defaults, etc.  (something a la microROS)
* A lightweight replacement of the node launch system suitable for
  integration with actual service managers. Likely just a set of tools
  for building node parameter files out of system configurations.
* A new client library built directly against a single chosen
  middleware, likely Zenoh. This would mainly be done to remove
  the layers of abstraction (complexity) at the lowest level,
  while also allowing full use of the capabilities offered by
  the middleware itself.
