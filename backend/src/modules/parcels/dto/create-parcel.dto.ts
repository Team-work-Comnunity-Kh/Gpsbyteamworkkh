import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsArray,
  ArrayMinSize,
  MinLength,
  MaxLength,
} from 'class-validator';

export class CreateParcelDto {
  @ApiProperty({ example: 'ដីកសិកម្ម ភូមិអន្លង់វែង' })
  @IsString()
  @MinLength(2)
  @MaxLength(200)
  name: string;

  @ApiProperty({ example: 'ដីកសិកម្ម ទំហំ 2 ហិកតា', required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({
    example: [[[104.9199, 11.5564], [104.9299, 11.5564], [104.9299, 11.5664], [104.9199, 11.5664]]],
    description: 'GeoJSON Polygon coordinates: rings containing [longitude, latitude] pairs',
  })
  @IsArray()
  @ArrayMinSize(1)
  coordinates: number[][][];

  @ApiProperty({ example: 'agricultural', required: false })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiProperty({ example: { soilType: 'clay', landUse: 'rice' }, required: false })
  @IsOptional()
  metadata?: Record<string, any>;

  @ApiProperty({ example: ['url1', 'url2'], required: false })
  @IsOptional()
  @IsArray()
  photos?: string[];

  @ApiProperty({ example: ['កសិកម្ម', 'ស្រែ'], required: false })
  @IsOptional()
  @IsArray()
  tags?: string[];

  @ApiProperty({ example: '#0FA3A3', required: false })
  @IsOptional()
  @IsString()
  color?: string;
}
