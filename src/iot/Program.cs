using System;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.Devices.Client;

namespace TimeSeriesAnalytics
{
    class Program
    {
        public static async Task<int> Main(string[] args)
        {
            

            using var deviceClient = DeviceClient.CreateFromConnectionString(
                "HostName=CovidHub.azure-devices.net;DeviceId=123;SharedAccessKey=bxRvXUBTDqZZQpqds8bX9y1BhPYdbtoehrDotGZOqvE=",
                TransportType.Mqtt);
            var sample = new MessageSample(deviceClient);
            await sample.RunSampleAsync(Int32.Parse(args[0]), Int32.Parse(args[1]));

            Console.WriteLine("Done.");
            return 0;
        }
    }

    public class MessageSample
    {
        private static readonly Random s_randomGenerator = new Random();
        private readonly DeviceClient _deviceClient;
        

        public MessageSample(DeviceClient deviceClient)
        {
            _deviceClient = deviceClient ?? throw new ArgumentNullException(nameof(deviceClient));
        }

        public async Task RunSampleAsync(int from, int to)
        {
            for (int i = from; i <= to; i++)
            {
                if(i==to)
                    await SendEventAsync(i.ToString());
                else
                    SendEventAsync(i.ToString());
                
            }
            
            //await ReceiveMessagesAsync();
        }

        private async Task SendEventAsync(string id)
        {
            const int MessageCount = 100;
            Console.WriteLine($"Device sending {MessageCount} messages to IoT Hub...\n");

            

            for (int count = 0; count < MessageCount; count++)
            {
                var _count = s_randomGenerator.Next(20, 200);
                

                string dataBuffer = $"{{\"Cameraid\": \"Camera {id}\" ,\"count\":{_count}}}";

                using var eventMessage = new Message(Encoding.UTF8.GetBytes(dataBuffer))
                {
                    ContentType = "application/json",
                    ContentEncoding = Encoding.UTF8.ToString(),
                };

                
                Console.WriteLine($"\t{DateTime.Now}> Sending message: {count}, data: [{dataBuffer}]");

                await _deviceClient.SendEventAsync(eventMessage);
                await Task.Delay(3000);
            }
        }
/*
        private async Task ReceiveMessagesAsync()
        {
            Console.WriteLine("\nDevice waiting for C2D messages from the hub...");
            Console.WriteLine("Use the Azure Portal IoT Hub blade or Azure IoT Explorer to send a message to this device.");

            using Message receivedMessage = await _deviceClient.ReceiveAsync(TimeSpan.FromSeconds(30));
            if (receivedMessage == null)
            {
                Console.WriteLine($"\t{DateTime.Now}> Timed out");
                return;
            }

            string messageData = Encoding.ASCII.GetString(receivedMessage.GetBytes());
            Console.WriteLine($"\t{DateTime.Now}> Received message: {messageData}");

            int propCount = 0;
            foreach (var prop in receivedMessage.Properties)
            {
                Console.WriteLine($"\t\tProperty[{propCount++}> Key={prop.Key} : Value={prop.Value}");
            }

            await _deviceClient.CompleteAsync(receivedMessage);
        }\*/
    }
    
}
