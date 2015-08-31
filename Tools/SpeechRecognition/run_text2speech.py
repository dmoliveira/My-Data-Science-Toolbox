import pyttsx
import sys

#
# Title: Text2Speech Class
# Description: This class is capable of read any text and transform to speech.
# Tags: Python, Speech, Text, Runnable
#


class Text2Speech(object):

    def __init__(self, rate=150, voice_id=-1):
        self.engine = pyttsx.init()
        self.engine.setProperty('rate', rate)
        self.voices = self.engine.getProperty('voices')
        self.engine.setProperty('voice', self.voices[0].id)

    def generate_output(self, text):
        self.engine.say(text)
        self.engine.runAndWait()


def main():
    """
        @args1: text
        @type: string
    """
    Text2Speech().generate_output(sys.argv[1])

if __name__ == '__main__':
    main()
