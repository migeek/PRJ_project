import sys
import os
import pydub
import requests
import time
from threading import Thread
import socketio
import json
import threading
import pygame
import pyaudio
import wave

import RPi.GPIO as GPIO # Import Raspberry Pi GPIO library

form_1 = pyaudio.paInt16  # 16-bit resolution
chans = 1  # 1 channel
samp_rate = 44100  # 44.1kHz sampling rate
chunk = 4096  # 2^12 samples for buffer
record_secs = 10  # seconds to record
dev_index = 2  # device index found by p.get_device_info_by_index(ii)

deviceNum = 1000
host = '97.97.187.69'
#host = 'localHost'
port = 9000

# now set up the socketio stuff
sio = socketio.Client()
server = f"http://{host}:{port}"
#server = f"http://{host}"

@sio.on('connect')
def on_connect():
    print(f'I\'m connected! to the server, successful!!!')


@sio.on('message')
def on_message(data):
    print('I received a message!', data)
    if data("type") == "messageCount":
        # read messages over HTTP
        recieveNumFromServer(data)
    else:
        print(f'Cannot handle data {data}')


@sio.on('connect_error')
def connect_error(message):
    print('Connection was rejected due to ' + message)


@sio.on('wakeUp')
def wakeUp(data):
    print('I received a message!', data)

    # receive token number which is used to send messages to the client
    global token
    token = data['token']
    print("token in wakeUp is ", data['token'])

    # create dictionary of all the device numbers and family order
    table = data['table']
    global family
    for item in table:
        family[item[1]] = item[0]
    print("dict is ", family)


@sio.on('messagesExist')
def getMessagesFromServer():
    statusCode = 200
    i = 0
    while statusCode != 204:
        req = requests.get(server)
        statusCode = req.status_code
        if statusCode == 200:
            i = i+1
            with open('messageRecieve' + str(i) + str(time.gmtime(0)) + '.mp3', 'wb') as f:
                f.write(req.content)
                f.close()


@sio.on('disconnect')
def on_disconnect():
    print('I\'m disconnected!')


def getArrayFromFile(fh):
    byteArray = []
    try:
        byte = fh.read(1)
        while byte != b"":
            byteArray.append(int.from_bytes(byte, byteorder=sys.byteorder))
            byte = fh.read(1)
    finally:
        fh.close()
    return byteArray


# message is 'myfile.mp3'
def send_audio(token, receiver):
    print('attempting to send audio')
    print("token in send_audio", token)
    print('family number', receiver)
    url = "http://97.97.187.69:9000/postMessage"


    audio = pyaudio.PyAudio()  # create pyaudio instantiation

    # create pyaudio stream
    stream = audio.open(format=form_1, rate=samp_rate, channels=chans, \
                        input_device_index=dev_index, input=True, \
                        frames_per_buffer=chunk)
    print("recording")
    frames = []

    # loop through stream and append audio chunks to frame array
    for ii in range(0, int((samp_rate / chunk) * record_secs)):
        data = stream.read(chunk)
        frames.append(data)

    print("finished recording")

    # stop the stream, close it, and terminate the pyaudio instantiation
    stream.stop_stream()
    stream.close()
    audio.terminate()
    wav_message= 'test.wav'
    wavefile = wave.open(wav_message, 'wb')
    wavefile.setnchannels(chans)
    wavefile.setsampwidth(audio.get_sample_size(form_1))
    wavefile.setframerate(samp_rate)
    wavefile.writeframes(b''.join(frames))
    wavefile.close()


    mp3file = convertToMP3(wav_message)
    file = open(mp3file, 'rb')
    byteArray = getArrayFromFile(file)
    print(mp3file)
    data = {'token': token, 'devNum': 1000, 'receiver': receiver, 'data': byteArray}
    req = requests.post(url, json=data)
    # print(req.status_code)
    # print(req.text)


def ifButtonPress(twc):
    print("Button was pushed!")
    receiver = family[3]
    send_audio_thread = Thread(target=twc.send_audio, args=(token, receiver, 'myfile.wav',))
    send_audio_thread.start()


def button_callback(channel):
    print("Button was pushed!")
    receiver = family[3]
    print(receiver)
    send_audio(token, receiver, 'myfile.wav')



def recieve_audio(messageCount):
    for i in range(messageCount):
        req = requests.get(server)
        print(req.content)
        with open('message_' + str(i) + str(time.gmtime(0)) + '.mp3', 'wb') as f:
            f.write(req.content)
            f.close()


def recieveNumFromServer(event):
    print(f'Reveived (fromServer): {event}')
    try:
        messageCount = event["messageCount"]
    except:
        messageCount = 0
    print(f"\n RECEIVED fromServer - {messageCount}")
    recieve_audio_thread = Thread(target=recieve_audio, args=(messageCount,))
    recieve_audio_thread.start()


def convertToMP3(wavFile):
    mp3File = os.path.splitext(wavFile)[0] + '.mp3'
    sound = pydub.AudioSegment.from_wav(wavFile)
    sound.export(mp3File, format="mp3")
    return mp3File


class TwoWayClient():

    def __init__(self):
        self.sioFlag = True
        sio.on('fromServer', self.fromServer)
        sio.on('connected', self.on_connected)

    def fromServer(self, event):
        recieveNumFromServer(event)

    def on_connected(self, event):
        print(f'I am connected!!!!!!!!!!: {event}')

    def send_audio(self, token, receiver, message):
        print('attempting to send audio')
        print("token in send_audio", token)
        print('family number', receiver)
        url = "http://97.97.187.69:9000/postMessage"

        mp3file = convertToMP3(message)
        file = open(mp3file, 'rb')
        byteArray = getArrayFromFile(file)
        print(byteArray)
        data = {'token': token, 'devNum': deviceNum, 'receiver': receiver, 'data': byteArray}
        # req = requests.post(url, json=data)
        # print(req.status_code)
        # print(req.text)

    def createThread(self):
        self.receive_events_thread = Thread(target=self._receive_events_thread)
        # self.receive_events_thread.daemon = True
        self.receive_events_thread.start()

    def _receive_events_thread(self):
        while (self.sioFlag):
            sio.sleep(1)

    def kill(self):
        self.join()


def main():
    #info = {'token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJkZXZOdW0iOiI1NjAwOTgifQ.K71Mq8FvatWXdYicT4PN84Q4EB3RY4v67YUHmTsR6t0', 'table': [['2C9737C04DF14814AEA5BFF7086EF99D', 1], ['B343513A87794CFAB53644590C4DA61E', 2], ['560098', 3]]}
    #wakeUp(info)
    print("token is ", token)
    sio.connect(server + '?devNum=1000')
    process = TwoWayClient()
    process.on_connected(on_connect)
    process.fromServer(on_message)
    process.createThread()
    print(threading.active_count())
    pygame.init()
    GPIO.setwarnings(False)  # Ignore warning for now
    GPIO.setmode(GPIO.BOARD)  # Use physical pin numbering
    GPIO.setup(10, GPIO.IN,
               pull_up_down=GPIO.PUD_DOWN)  # Set pin 10 to be an input pin and set initial value to be pulled low (off)
    GPIO.add_event_detect(10, GPIO.RISING, callback=button_callback, bouncetime=400)  # Setup event on pin 10 rising edge
    # message = input("Press enter to quit\n\n")  # Run until someone presses enter
    print("done with main")


if __name__ == "__main__":
    main()
