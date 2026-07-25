# ROS2 토커·리스너 토픽 통신 실습

## 실습 내용

ROS2의 발행자 노드인 `talker`와 구독자 노드인 `listener`를 실행하고,
`/chatter` 토픽을 통해 메시지가 전달되는 과정을 확인했다.

## 실행한 명령어

```bash
ros2 run demo_nodes_cpp talker
ros2 run demo_nodes_py listener
ros2 topic echo /chatter
ros2 topic info /chatter
ros2 interface show std_msgs/msg/String
