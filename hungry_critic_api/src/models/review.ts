import { Allow, IsDefined, IsPositive } from "class-validator";

export class Review {

    @Allow()
    author: string;

    @IsDefined()
    restaurant: string;

    @IsPositive()
    rating: number;

    @Allow()
    review: string;

    @IsPositive()
    timestamp: number;
}