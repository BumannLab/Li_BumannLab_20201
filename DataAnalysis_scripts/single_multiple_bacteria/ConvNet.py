# -*- coding: utf-8 -*-
"""
Created on Fri Nov 16 17:20:33 2018

@author: Melnse
"""

#%% import block
#import tensorflow as tf
import torch
import torch.nn.functional as F
from torch import autograd, nn
from torch.autograd import Variable
import numpy as np
import matplotlib.pyplot as plt
from torchvision import transforms, datasets
from torch.utils.data import Dataset, DataLoader
import os
import matplotlib.pyplot as plt
import torch.optim as optim

__spec__ = None
#%% load data
def load_data(data_dir):
    transform = transforms.Compose([
        #transforms.Scale(args.image_size),
        #transforms.CenterCrop(args.image_size),
        transforms.ToTensor(),
        #transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5)),
    ])
    return datasets.ImageFolder(root=data_dir,transform=transform)

def show_sample(image):
    """Show image with landmarks"""
    plt.imshow(image.transpose((1,2,0)))
    plt.pause(0.001)  # pause a bit so that plots are updated



#%% Display data
def imshow(inp, title=None, save_to_file=False):
    """Imshow for Tensor."""
    inp = inp.numpy().transpose((1, 2, 0))
    mean = np.array([0.5, 0.5, 0.5])
    std = np.array([0.5, 0.5, 0.5])
    inp = std * inp + mean
    inp = np.clip(inp, 0, 1)
    inp /= inp.max()
    plt.imshow(inp)
    #print(title)
    if save_to_file:
       plt.imsave('/home/natasha/Programming/Python_wd/single_multiple_bacteria/error/{}.png'.format(title), inp)
    if title is not None:
        plt.title(title)
    plt.pause(0.001)  # pause a bit so that plots are updated    


def show_several(imgs, labels, num_images):
    images_so_far = 0
    fig = plt.figure()
    for i in range(len(labels)):
        images_so_far += 1
        ax = plt.subplot(num_images//2, 2, images_so_far)
        ax.axis('off')
        ax.set_title('label: {}'.format(labels[i]))
        imshow(imgs[i])
        if images_so_far == num_images:
                return


def visualize_model(model, num_images=6):
    images_so_far = 0
    fig = plt.figure()

    for i, data in enumerate(dataloaders['val']):
        inputs, labels = data
        inputs, labels = Variable(inputs.cuda()), Variable(labels.cuda())

        outputs = model(inputs)
        _, preds = torch.max(outputs.data, 1)

        for j in range(inputs.size()[0]):
            images_so_far += 1
            ax = plt.subplot(num_images//2, 2, images_so_far)
            ax.axis('off')
            ax.set_title('predicted: {}'.format(class_names[preds[j]]))
            imshow(inputs.cpu().data[j])

            if images_so_far == num_images:
                return
    
    
#%% nn module            
class BactModel(nn.Module):
    
    def __init__(self):
        super(BactModel, self).__init__()
        #self.layer1 = nn.Conv2d(in_channels=3, out_channels=20, kernel_size=5, stride=1, padding=2)        
        self.layer1 = nn.Sequential(
            nn.Conv2d(in_channels=3, out_channels=20, kernel_size=5, stride=1, padding=2),
            #nn.BatchNorm2d(16),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2, stride=2))
        
        #self.layer2 = nn.Conv2d(in_channels=20, out_channels=20, kernel_size=3, stride=1, padding=1)
        self.layer2 = nn.Sequential(
            nn.Conv2d(in_channels=20, out_channels=32, kernel_size=3, stride=1, padding=1),
            #nn.BatchNorm2d(32),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2, stride=2))
        #self.layer3 = nn.Conv2d(in_channels=20, out_channels=20, kernel_size=3, stride=1, padding=1)
        self.layer3 = nn.Sequential(
            nn.Conv2d(in_channels=32, out_channels=64, kernel_size=3, stride=1, padding=1),
            #nn.BatchNorm2d(32),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=3, stride=3))
        
        self.fc = nn.Linear(3 * 3 * 64, 2)
        #self.fc = nn.Linear(3 * 3 * 20, 2)
        
        
    def forward(self, x):
        #x = self.pool(F.relu(self.layer1(x)))
        #print(x.size())
        out = self.layer1(x)
        #print(out.size())
        #x = self.pool(F.relu(self.layer2(x)))
        out = self.layer2(out)
        #print(out.size())
        #print(x.size())
        #x = F.relu(self.layer3(x))
        out = self.layer3(out)
        #print(out.size())
        #print(x.size())
        #x = self.pool3(x)
        out = out.reshape(out.size(0), -1)
        #print(out.size())
        #print(x.size())
        #x = x.view(-1, 3 * 3 * 20)
        out = self.fc(out)
        #print(out.size())
        #x = self.fc(x)
        #print(x.size())
        return out


class BactModel_default(nn.Module):
    def __init__(self):
        super(BactModel_default, self).__init__()
        self.layer1 = nn.Sequential(
            nn.Conv2d(in_channels=3, out_channels=20, kernel_size=5, stride=1, padding=2),
            #nn.BatchNorm2d(16),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2, stride=2))
        
        #self.layer2 = nn.Conv2d(in_channels=20, out_channels=20, kernel_size=3, stride=1, padding=1)
        self.layer2 = nn.Sequential(
            nn.Conv2d(in_channels=20, out_channels=20, kernel_size=3, stride=1, padding=1),
            #nn.BatchNorm2d(32),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2, stride=2))
        #self.layer3 = nn.Conv2d(in_channels=20, out_channels=20, kernel_size=3, stride=1, padding=1)
        self.layer3 = nn.Sequential(
            nn.Conv2d(in_channels=20, out_channels=20, kernel_size=3, stride=1, padding=1),
            #nn.BatchNorm2d(32),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=3, stride=3))
        
        self.fc = nn.Linear(3 * 3 * 20, 2)
        
    def forward(self, x):
        out = self.layer1(x)
        out = self.layer2(out)
        out = self.layer3(out)
        out = out.reshape(out.size(0), -1)
        out = self.fc(out)
        return out


class BactModel_default_binary(nn.Module):
    def __init__(self):
        super(BactModel_default_binary, self).__init__()
        self.layer1 = nn.Sequential(
            nn.Conv2d(in_channels=3, out_channels=20, kernel_size=5, stride=1, padding=2),
            #nn.BatchNorm2d(16),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2, stride=2))
        
        #self.layer2 = nn.Conv2d(in_channels=20, out_channels=20, kernel_size=3, stride=1, padding=1)
        self.layer2 = nn.Sequential(
            nn.Conv2d(in_channels=20, out_channels=20, kernel_size=3, stride=1, padding=1),
            #nn.BatchNorm2d(32),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=2, stride=2))
        #self.layer3 = nn.Conv2d(in_channels=20, out_channels=20, kernel_size=3, stride=1, padding=1)
        self.layer3 = nn.Sequential(
            nn.Conv2d(in_channels=20, out_channels=20, kernel_size=3, stride=1, padding=1),
            #nn.BatchNorm2d(32),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=3, stride=3))
        
        self.fc = nn.Linear(3 * 3 * 20, 1)
        self.out_act = nn.Sigmoid()
        
    def forward(self, x):
        out = self.layer1(x)
        out = self.layer2(out)
        out = self.layer3(out)
        out = out.reshape(out.size(0), -1)
        out = self.fc(out)
        out = self.out_act(out)
        return out
    
#%% transform data
class NormalizeToOne(object):
    def __call__(self, sample):
        #print(sample)
        sample /= torch.max(sample);
        return sample
        
#%% configuration
# Device configuration
device = torch.device('cuda:0' if False else 'cpu')
batch_size = 10
learning_rate = 0.001


#%% process data
#dataset = load_data('..\\data\\fouga')
data_transform_1 = transforms.Compose([
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        NormalizeToOne(),
        transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))
    ])
train_dataset = datasets.ImageFolder(root='/home/natasha/Programming/Python_wd/single_multiple_bacteria/Train/', transform=data_transform_1)
val_dataset = datasets.ImageFolder(root='/home/natasha/Programming/Python_wd/single_multiple_bacteria/Val/', transform=data_transform_1)


dataset_loader = torch.utils.data.DataLoader(train_dataset,
                                             batch_size=batch_size,
                                             shuffle=True, # set this to true while training!
                                             num_workers=0)
validation_loader = torch.utils.data.DataLoader(val_dataset,
                                             batch_size=1,
                                             shuffle=False, # set this to true while training!
                                             num_workers=0)

#net = BactModel().to(device)
#net = BactModel_default().to(device)
#criterion = nn.CrossEntropyLoss()
##optimizer = optim.SGD(net.parameters(), lr=0.001, momentum=0.9)
#optimizer = torch.optim.Adam(net.parameters(), lr=learning_rate)
#scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=50, gamma=0.1)     
#%% Train
#for epoch in range(160):  # loop over the dataset multiple times
#    running_loss = 0.0
#    total_loss = 0.0
#    count = 0
#    scheduler.step()
#    for i, data in enumerate(dataset_loader, 0):
#        # get the inputs
#        inputs, labels = data
#        inputs = inputs.to(device)
#        labels = labels.to(device)
#        #show_several(inputs, labels, 6)
#        # zero the parameter gradients
#        # forward + backward + optimize
#        outputs = net(inputs)
#        #print(outputs)
#        #print(labels)
#        loss = criterion(outputs, labels)
#        optimizer.zero_grad()        
#        loss.backward()
#        optimizer.step()
#
#        # print statistics
#        count += 1
#        total_loss += loss.item()
#        running_loss += loss.item()
#        if i % 10 == 9:    # print every 2000 mini-batches
#            print('[%d, %5d] loss: %.3f' %
#                  (epoch + 1, i + 1, running_loss / 10))
#            running_loss = 0.0
#
#    print('Epoch loss: %.3f' % (total_loss / count))
#print('Finished Training')


#%% binary model
#net = BactModel().to(device)
net = BactModel_default_binary().to(device)
criterion = nn.BCELoss()
#optimizer = optim.SGD(net.parameters(), lr=0.001, momentum=0.9)
optimizer = torch.optim.Adam(net.parameters(), lr=learning_rate)
scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=50, gamma=0.1)     

#%% Train binary model

for epoch in range(160):  # loop over the dataset multiple times
    running_loss = 0.0
    total_loss = 0.0
    count = 0
    scheduler.step()
    for i, data in enumerate(dataset_loader, 1):
        # get the inputs
        inputs, labels = data
        inputs = inputs.to(device)
        labels = labels.to(device)
        #show_several(inputs, labels, 6)
        # zero the parameter gradients
        # forward + backward + optimize
        outputs = net(inputs)
        #print(outputs)
        #print(labels)
        loss = criterion(outputs, labels.float())
        optimizer.zero_grad()        
        loss.backward()
        optimizer.step()

        # print statistics
        count += 1
        total_loss += loss.item()
        running_loss += loss.item()
        if i % 10 == 9:    # print every 2000 mini-batches
            print('[%d, %5d] loss: %.3f' %
                  (epoch + 1, i + 1, running_loss / 10))
            running_loss = 0.0

    print('Epoch loss: %.3f' % (total_loss / count))
print('Finished Training')

#%% test model in test data
# Test the model
#net.eval()  # eval mode (batchnorm uses moving mean/variance instead of mini-batch mean/variance)
#with torch.no_grad():
#    correct = 0
#    total = 0
#    for images, labels in dataset_loader:
#        images = images.to(device)
#        labels = labels.to(device)
#        outputs = net(images)
#        _, predicted = torch.max(outputs.data, 1)
#        total += labels.size(0)
#        correct += (predicted == labels).sum().item()
#
#    print('Test Accuracy of the model on the training images: {} %'.format(100 * correct / total))
#    
#%% test model in validation data
#net.eval()  # eval mode (batchnorm uses moving mean/variance instead of mini-batch mean/variance)
#with torch.no_grad():
#    correct = 0
#    total = 0
#    failed = 0
#    for images, labels in validation_loader:
#        images = images.to(device)
#        labels = labels.to(device)
#        outputs = net(images)
#        print(outputs)
#        _, predicted = torch.max(outputs.data, 1)
#        total += labels.size(0)
#        correct += (predicted == labels).sum().item()
#        if predicted != labels:
#            imshow(images[0].to('cpu'), '{}_labeled {} predicted {}'.format(failed, val_dataset.classes[labels[0]], val_dataset.classes[predicted[0]]), True)
#            failed += 1
#
#    print('Test Accuracy of the model on the validation images: {} %. Correct {} of {}'.format(100 * correct / total, correct, total))
    
#%% save model
#torch.save(net.state_dict(), 'model_default.ckpt')

#%% Test binary model
net.eval()  # eval mode (batchnorm uses moving mean/variance instead of mini-batch mean/variance)
t = torch.Tensor([0.5]).to(device)
with torch.no_grad():
    correct = 0
    total = 0
    correct_cnt = 0

    for images, labels in dataset_loader:
        images = images.to(device)
        labels = labels.float().to(device)
        outputs = net(images)
        #print(outputs)
        _, predicted = torch.max(outputs.data, 1)
        predicted = torch.reshape(((outputs > t).float() * 1), [1,predicted.size(0)])
       # print(predicted)
#        print(labels.size(0))
#        print(predicted.shape)
#        print(labels.shape)
#        print(predicted == labels)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()
        
        if predicted != labels:
           inp =  images[0].to('cpu')
           inp = inp.numpy().transpose((1, 2, 0))
           title =  '{}_labeled {} predicted {}'.format(correct_cnt, val_dataset.classes[labels[0].int()], val_dataset.classes[predicted[0].int()])
           plt.imsave('/home/natasha/Programming/Python_wd/single_multiple_bacteria/results/{}.png'.format(title), inp)           
           correct_cnt +=1  

    print('Test Accuracy of the model on the training images: {} %'.format(100 * correct / total))
#%%
with torch.no_grad():
    correct = 0
    total = 0
    failed = 0
    for images, labels in validation_loader:
        images = images.to(device)
        labels = labels.float().to(device)
        outputs = net(images)
        #print(outputs)
        _, predicted = torch.max(outputs.data, 1)
        predicted = torch.reshape(((outputs > t).float() * 1), [1,predicted.size(0)])

       # predicted = ((outputs > t).float() * 1).reshape(predicted.size(0), -1)
        #print(predicted)
#        print(labels.size(0))
#        print(predicted.shape)
#        print(labels.shape)
#        print(predicted == labels)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()
        if predicted != labels:
           imshow(images[0].to('cpu'), '{}_labeled {} predicted {}'.format(failed, val_dataset.classes[labels[0].int()], val_dataset.classes[predicted[0].int()]), True)
           failed += 1

           
    print('Test Accuracy of the model on the validation images: {} %'.format(100 * correct / total))
        