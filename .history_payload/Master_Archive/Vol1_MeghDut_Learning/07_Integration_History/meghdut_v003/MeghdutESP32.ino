#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "MEGHDUT_NET";
const char* password = "password";
const char* mqtt_server = "broker.hivemq.com";
const char* drone_id = "DRONE_ESP_002";

WiFiClient espClient;
PubSubClient client(espClient);

void setup_wifi() {
  delay(10);
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");
}

void reconnect() {
  while (!client.connected()) {
    if (client.connect(drone_id)) {
      Serial.println("MQTT connected");
    } else {
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200); // MAVLink Serial input
  setup_wifi();
  client.setServer(mqtt_server, 1883);
}

void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  // In a real scenario, we parse MAVLink bytes from Serial here.
  // For the integration test, we construct the JSON payload.
  
  String topic = String("meghdut/telemetry/") + drone_id;
  String payload = "{\"droneId\":\"" + String(drone_id) + "\", \"lat\": 17.3850, \"lng\": 78.4867, \"alt\": 120.5}";
  
  client.publish(topic.c_str(), payload.c_str());
  delay(100); // 10Hz update rate
}
