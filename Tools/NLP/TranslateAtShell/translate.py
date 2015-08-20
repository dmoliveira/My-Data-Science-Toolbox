#!/usr/bin/env python
#coding:utf-8
from textblob import TextBlob
import sys

ENCODING = 'UTF-8'

class TranslateAtShell(object):

    @staticmethod
    def translate(text, from_language, to_language):
        """
            translate: Translate from/to language. Uses Google Translate.

            Params:
            - text: The text that will be translated.
            - from_language: The language from.
            - to_language: The langue that will be translated.

            Results:
            - text translated in string format.
        """
        textBlob = TextBlob(text.decode(ENCODING, 'ignore'))
        
        if not from_language:
            from_language = textBlob.detect_language()

        return textBlob.translate(from_lang=from_language, to=to_language)
        
def main():

    if len(sys.argv) != 4 or not (sys.argv[1] and sys.argv[3]):
        raise Exception('''
                Argument Error
                --------------
    
                Please inform text and language from/to translate as arguments.
                
                e.g., 
                    "Esse é um texto que será traduzido." "pt" "en"
    
                To see all languages enabled check google translate API docs:
                https://sites.google.com/site/tomihasa/google-language-codes
                
                ''')
    
    text=sys.argv[1]
    from_language=sys.argv[2]
    to_language=sys.argv[3]

    return TranslateAtShell.translate(text, from_language, to_language)

if __name__ == '__main__':
    print main()
