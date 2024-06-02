# Zeros - Zig Entombment of ROS 2 (WIP)

A very much work in progress of an alternative approach to ROS 2
development including a client library, message generation, package
build support, and so on; for developing simple and efficient robotics
applications while minimizing contact surface with awful languages,
dreadful compile times, (micro) dependency hell, and other common
afflictions.

## Client library

A fully-featured (eventually) client library based on `rcl` and `rclc`.

### TODO

* Context
* Subscriptions
* Publishers
* Services
* Actions
* Parameters
* Timers
* Executors

## Message generation

### TODO

* Everything

## Build support

### TODO

* Everything
* Build time interaction with installed ROS 2 packages as created by ament.

## Other

* Runtime interaction with installed ROS 2 resources

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
