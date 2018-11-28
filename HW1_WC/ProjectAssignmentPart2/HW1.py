# -*- coding: utf-8 -*-
"""
Created on Tue Oct 30 13:13:51 2018

@author: jacky
"""
#import libraries
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics.pairwise import euclidean_distances
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.manifold import MDS
from mpl_toolkits.mplot3d import Axes3D
from scipy.cluster.hierarchy import ward, dendrogram

#load the data (13 books from the zip file)
filenames = [
'Austen_Emma.txt', 'Austen_Pride.txt',
'Austen_Sense.txt', 'CBronte_Jane.txt',
'CBronte_Professor.txt', 'CBronte_Villette.txt', 'Dickens_Bleak.txt',
'Dickens_David.txt', 'Dickens_Hard.txt', 'EBronte_Wuthering.txt', 'Eliot_Adam.txt', 
'Eliot_Middlemarch.txt', 'Eliot_Mill.txt']

#vectorize and convert to various data structures
vectorizer = CountVectorizer(input='filename')
dtm = vectorizer.fit_transform(filenames) 
print(type(dtm))
vocab = vectorizer.get_feature_names() #change to a list
dtm = dtm.toarray() #convert to a regular array
print(list(vocab)[500:550])

#counting words
house_idx = list(vocab).index('house')
print(house_idx)
print(dtm[0, house_idx]) #number of occurrences of 'house' in Emma
print(dtm[1, house_idx]) #number of occurrences of 'house' in Pride
print(list(vocab)[house_idx]) #print out 'house'
print(dtm) #print the doc term matrix

#create a word count table for all 13 books
columns = ["BookName", "house", "and", "almost"]
MyList = ["Emma"]
MyList2 = ["Pride"]
MyList3 = ["Sense"]
MyList4 = ["Jane"]
MyList5 = ["Professor"]
MyList6 = ["Villette"]
MyList7 = ["Bleak"]
MyList8 = ["David"]
MyList9 = ["Hard"]
MyList10 = ["Wuthering"]
MyList11 = ["Adam"]
MyList12 = ["Middlemarch"]
MyList13 = ["Mill"]
#hard coding to get all counts
for someword in ["house", "and", "almost"]:
    EmmaWord = (dtm[0, list(vocab).index(someword)])
    MyList.append(EmmaWord)
    PrideWord = (dtm[1, list(vocab).index(someword)])
    MyList2.append(PrideWord)
    SenseWord = (dtm[2, list(vocab).index(someword)])
    MyList3.append(SenseWord)
    JaneWord = (dtm[3, list(vocab).index(someword)])
    MyList4.append(JaneWord)
    ProfessorWord = (dtm[4, list(vocab).index(someword)])
    MyList5.append(ProfessorWord)
    VilletteWord = (dtm[5, list(vocab).index(someword)])
    MyList6.append(VilletteWord)
    BleakWord = (dtm[6, list(vocab).index(someword)])
    MyList7.append(BleakWord)
    DavidWord = (dtm[7, list(vocab).index(someword)])
    MyList8.append(DavidWord)
    HardWord = (dtm[8, list(vocab).index(someword)])
    MyList9.append(HardWord)
    WutheringWord = (dtm[9, list(vocab).index(someword)])
    MyList10.append(WutheringWord)
    AdamWord = (dtm[10, list(vocab).index(someword)])
    MyList11.append(AdamWord)
    MiddlemarchWord = (dtm[11, list(vocab).index(someword)])
    MyList12.append(MiddlemarchWord)
    MillWord = (dtm[12, list(vocab).index(someword)])
    MyList13.append(MillWord)
#create a pandas dataframe to store information
df2 = pd.DataFrame([columns, MyList, MyList2, MyList3, MyList4, MyList5, 
                    MyList6, MyList7, MyList8, MyList9, MyList10, MyList11, MyList12, MyList13])
print(df2)

#calculate distance between documents
#Euclidean Distance
dist = euclidean_distances(dtm)
print(np.round(dist, 0))
#Cosine Similarity
cosdist = 1 - cosine_similarity(dtm)
print(np.round(cosdist, 3))

#Visualizations (three methods)
#visualize in 2D
mds = MDS(n_components = 2, dissimilarity = "precomputed", random_state = 1) #"precomputed" -> cosine similarity
pos = mds.fit_transform(cosdist) #shape (n_components, n_samples)
xs, ys = pos[:, 0], pos[:, 1]
names = ['Austen_Emma', 'Austen_Pride',
'Austen_Sense', 'CBronte_Jane',
'CBronte_Professor', 'CBronte_Villette', 'Dickens_Bleak',
'Dickens_David', 'Dickens_Hard', 'EBronte_Wuthering', 'Eliot_Adam', 
'Eliot_Middlemarch', 'Eliot_Mill']
for x, y, name in zip(xs, ys, names):
    plt.scatter(x, y, color = "blue")
    plt.text(x, y, name, fontsize = 10)
    plt.title("Visualization in 2D")
#fig = plt.figure()
#fig.savefig('2D.png')
plt.show()

#visualize in 3D
mds = MDS(n_components = 3, dissimilarity = "precomputed", random_state = 1)
pos = mds.fit_transform(cosdist)
fig = plt.figure()
ax = fig.add_subplot(111, projection = '3d')
ax.scatter(pos[:, 0], pos[:, 1], pos[:, 2]) #3D
for x, y, z, s in zip(pos[:, 0], pos[:, 1], pos[:, 2], names):
    ax.text(x, y, z, s, fontsize = 8)
ax.set_xlim3d(-0.06, 0.06) #stretch out the x axis
ax.set_ylim3d(-0.01, 0.006) #stretch out the y axis
ax.set_zlim3d(-0.06, 0.16) #stretch out the z axis
plt.title("Visualization in 3D")
#fig.savefig('3D.png')
plt.show()

#visualize with hierarchical clustering
linkage_matrix = ward(cosdist) #Ward's method
dendrogram(linkage_matrix, orientation = "right", labels = names)
plt.tight_layout()
plt.title("Visualization in Hierarchical Clustering")
#fig = plt.figure()
#fig.savefig('Hierarchical.png')
plt.show()












