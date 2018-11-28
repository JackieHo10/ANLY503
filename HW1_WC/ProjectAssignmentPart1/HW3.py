# -*- coding: utf-8 -*-
"""
Created on Fri Nov  2 17:29:59 2018

@author: jacky
"""
#import libraries
import re
import string
import pandas as pd
import matplotlib.pyplot as plt
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from collections import Counter 
from wordcloud import WordCloud

#transform json file to pandas dataframe
tweetdf = pd.read_json("Twitter.json", lines = True)
tweetdf_text = tweetdf['text']

#tokenize and data cleaning
filtered_sentence_all = []
max_number_twitter = int(input("the max number of tweets you just entered last time: "))
for i in range(0, max_number_twitter):
    tweet = tweetdf_text[i]
    word_tokens = word_tokenize(tweet)
    #print(tweet)
    #print(word_tokens)
    stop_words = stopwords.words('english') #remove English stopwords
    stop = stop_words + list(string.punctuation) + ["https", "rt", "RT", 
                            "CO", "co", "bigbutt"] #remove punctuations and additional contents
    filtered_sentence = [] 
    for w in word_tokens: 
        if w not in stop: 
            filtered_sentence.append(w)  
    #print(filtered_sentence) 
    filtered_sentence_all = filtered_sentence_all + filtered_sentence #combine two lists
print(filtered_sentence_all)
print(Counter(filtered_sentence_all)) #do word count

#save the output to a text file
def out_fun():
    return str(Counter(filtered_sentence_all)) + "\n" #new line label to solve Tableau
output = out_fun()
file = open("count_tweets.txt", "w", encoding = "utf-8")
file.write(output)
file.close()

def out_fun_1():
    return str(filtered_sentence_all).replace(",", "\n") + "\n" #new line label to solve Tableau
output_1 = out_fun_1()
#emoji_pattern = re.compile("["
#        u"\U0001F600-\U0001F64F"  
#        u"\U0001F300-\U0001F5FF"  
#        u"\U0001F680-\U0001F6FF"  
#        u"\U0001F1E0-\U0001F1FF"  
#                           "]+", flags = re.UNICODE)
#output_2 = emoji_pattern.sub(r'', output_1) #remove emoji
output_2 = re.sub("[^A-Za-z0-9]", " ", output_1)
output_3 = re.sub(" \d+", " ", output_2 )
file_1 = open("normal_tweets.txt", "w", encoding = "utf-8")
file_1.write(output_3)
file_1.close()

#create a wordcloud based on the above
stopwords = stop
comment_words = ' '
for x in range(len(filtered_sentence_all)): 
    filtered_sentence_all[x] = filtered_sentence_all[x].lower() 
for words in filtered_sentence_all: 
    comment_words = comment_words + words + ' '
wordcloud = WordCloud(width = 800, height = 800, 
                background_color ='white', 
                stopwords = stopwords, 
                min_font_size = 10).generate(comment_words) 
  
#plot the WordCloud                        
plt.figure(figsize = (8, 8), facecolor = None) 
plt.imshow(wordcloud) 
plt.axis("off") 
plt.tight_layout(pad = 0) 
  
plt.show() 