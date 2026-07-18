#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Character.h"
UCLASS()
class GAME_API APlayerCharacter : public ACharacter { GENERATED_BODY() UPROPERTY(EditAnywhere) float Speed; UFUNCTION() void Attack(); };
