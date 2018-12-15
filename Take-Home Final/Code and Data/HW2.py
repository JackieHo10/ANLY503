# -*- coding: utf-8 -*-
"""
Created on Fri Nov  2 14:11:18 2018

@author: jacky
"""
#import libraries
import sys
import tweepy
from tweepy import OAuthHandler
from tweepy import Stream
from tweepy.streaming import StreamListener
#import json
#import re
#import matplotlib.pyplot as plt
#import pandas as pd
#from nltk.tokenize import word_tokenize
#from nltk.tokenize import TweetTokenizer
#from os import path
#from scipy.misc import imread
#from wordcloud import WordCloud, STOPWORDS

#twitter developer account information
consumer_key = 'WZyeqNt1yUP6OFRBzfQN4ho7Z'
consumer_secret = 'DfMcZsJbSMZcFCLpfxgySqqqbXDCKZSazs8ED8GMjxYREWU71b'
access_token = '1058132943850401792-yEEByQSQDHRu47rWVaA1crfmF95iZv'
access_secret = 'rjkXCbZaZXyb9eekdR2Lrc2MXnAWk5fPkstpv7CC57Nlq'

#set up the API
auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_secret)
api = tweepy.API(auth)

#get tweets from Twitter
class MyListener(StreamListener):
    print("StreamListener...")
    tweet_number = 0 #initialize the counter
    #__init__runs when an instance of the class is created
    def __init__(self, max_tweets):
        self.max_tweets = max_tweets #set max number of tweets
        print("max number of tweets: ", self.max_tweets) 
    def on_data(self, data):
        self.tweet_number += 1 #update number of tweets
        print("get tweet # ", self.tweet_number)
        #print(self.tweet_number, self.max_tweets)
        if self.tweet_number > self.max_tweets:
            sys.exit("reach the limit of" + " " + str(self.max_tweets)) #stop point
        try:
            print("writing data into json")
            with open('Twitter.json', 'a') as f:
                f.write(data)
                return True #output tweets in json format/one tweet per line
        except BaseException:
            print("Wrong")
            return True        
    #method for on_error (error handler)    
    def on_error(self, status):
        print("Error")
        if(status == 420):
            print("Error ", status, "rate limited") #Twitter API rate limit
            return False

#get user input to run and do error check
max_tweets = int(input("What is the max number of tweets? (must be an integer bigger than 0) "))
if max_tweets > 30 or max_tweets <= 0:
    sys.exit("the max set is 30 and the min set is 1")

hashtag = str(input("What is the hashtag? (must include # at the beginning) "))
if hashtag.find("#") != 0:
    sys.exit("must include # at the beginning")

twitter_stream = Stream(auth, MyListener(max_tweets)) #assign the max_tweets
twitter_stream.filter(track=[hashtag]) #assign hashtag to filter







