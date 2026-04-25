import json
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
from stable_baselines3 import PPO
import os

class DemoDataset(Dataset):
    def __init__(self, recordings_path):
        self.data = []
        for filename in os.listdir(recordings_path):
            if filename.endswith(".json"):
                with open(os.path.join(recordings_path, filename)) as f:
                    self.data.extend(json.load(f))
        print(f"loaded {len(self.data)} steps from recordings!")

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        step = self.data[idx]
        obs = torch.tensor(step["obs"], dtype=torch.float32)
        move = torch.tensor(step["move"], dtype=torch.long)
        jump = torch.tensor(step["jump"], dtype=torch.long)
        return obs, move, jump

class BehavioralCloning(nn.Module):
    def __init__(self):
        super().__init__()
        self.network = nn.Sequential(
            nn.Linear(7, 64),
            nn.ReLU(),
            nn.Linear(64, 64),
            nn.ReLU(),
        )
        self.move_head = nn.Linear(64, 2)
        self.jump_head = nn.Linear(64, 2)

    def forward(self, x):
        features = self.network(x)
        return self.move_head(features), self.jump_head(features)

def train():
    recordings_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "recordings/")
    dataset = DemoDataset(recordings_path)
    dataloader = DataLoader(dataset, batch_size=64, shuffle=True)

    model = BehavioralCloning()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    criterion = nn.CrossEntropyLoss()

    print("training ai...")
    for epoch in range(50):
        total_loss = 0
        for obs, move, jump in dataloader:
            optimizer.zero_grad()
            move_pred, jump_pred = model(obs)
            loss = criterion(move_pred, move) + criterion(jump_pred, jump)
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
        
        if epoch % 10 == 0:
            print(f"Epoch {epoch}/50 - Loss: {total_loss:.4f}")

    os.makedirs("models", exist_ok=True)
    torch.save(model.state_dict(), "models/behavioral_cloning.pth")
    print("model saved.")

if __name__ == "__main__":
    train()