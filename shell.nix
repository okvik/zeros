{ pkgs }:

pkgs.mkShell {
  name = "zeros";
  packages = (with pkgs; [
    zigpkgs.master-2024-09-03
    zls
  ]) ++ (with pkgs.rosPackages.humble; [
    (buildEnv {
      paths = [
        ros-environment
        ros2run
        ros2topic
        ros2node
        rclc-examples
        rclc
        std-msgs
        geometry-msgs
        actionlib-msgs
        action-msgs
        unique-identifier-msgs
        builtin-interfaces
        rcl-interfaces
        rosidl-typesupport-interface
        rmw-cyclonedds-cpp
        rmw-fastrtps-cpp

        # service-msgs
        # rosidl-dynamic-typesupport
        # type-description-interfaces
      ];
    })
  ]);
  RMW_IMPLEMENTATION="rmw_cyclonedds_cpp";
}
