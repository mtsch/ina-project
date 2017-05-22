#!/usr/bin/env python3
import networkx as nx
import community
from sklearn import metrics
import csv
import collections
import math

def get_true_labels():
    with open('../models/iCHOv1-model/iCHOv1-meta-connected.csv') as f:
        reader = csv.reader(f)
        next(reader)  # Skip header

        label_names = [row[3] for row in reader]
        labels = []
        for idx, count in enumerate(collections.Counter(label_names).values()):
            labels.extend([idx] * count)
        return labels


if __name__ == '__main__':
    G = nx.read_edgelist('../models/iCHOv1-model/iCHOv1-connected.edgelist', nodetype=int)
    partition = community.best_partition(G)
    labels_pred = list(partition.values())
    labels_true = get_true_labels()
    assert len(labels_pred) == len(labels_true)
    print(metrics.mutual_info_score(labels_pred, labels_true) / math.log(len(labels_pred)))