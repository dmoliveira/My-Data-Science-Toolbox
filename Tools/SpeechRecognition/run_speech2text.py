#!/usr/bin/env python

import speech_recognition as sr


class MyPersonalAI(object):

    def __init__(self):
        self.r = sr.Recognizer()

    def recognize_speech(self):
        self.generate_output("Recording...")
        with sr.Microphone() as source:
            audio = self.r.listen(source)
            try:
                return self.r.recognize(audio)
            except LookupError:
                self.generate_output("[!] Could not understand audio")

    def generate_output(self, text, is_to_print=True, is_to_speech=True):
        print(text)


def main():
    ada = MyPersonalAI()
    ada.recognize_speech()

if __name__ in '__main__':
    main()
